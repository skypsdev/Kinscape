module Api
  module V1
    class PublicationsController < BaseController
      after_action :set_headers, only: [:index]

      def index
        authorize! :read, Publication
        @pagy, records = pagy(filtered_publications, items: 10)
        options = {
          include: [:family, :story],
          params: { unread: unread_list(filtered_publications) },
          fields: {
            family: [:name, :cover_url],
            publication: PublicationSerializer.attributes_to_serialize.keys.excluding(:all_publications) +
                         [:family, :story],
            story: StorySerializer.attributes_to_serialize.keys.excluding(:full_size_cover_url, :links)
          }
        }
        response_service.render_collection(PublicationSerializer, records, options: options)
      end

      def show
        authorize! :read, publication
        publication.story.mark_as_read! for: current_user
        options = { include: [:all_comments, :story, :'story.publications', :'story.families'] }
        response_service.render(PublicationSerializer, publication, options: options)
      end

      def create
        publication = Publication.includes(:family, :story).find(create_params[:id])
        authorize! :create_another, publication
        publications = ::Publications::CreationService.call(publication.story, current_user, create_params)
        response_service.render_collection(PublicationSerializer, publications)
      rescue Date::Error
        # TODO: move it to service and return as an error in AR
        response_service.render_forbidden
      end

      def destroy
        authorize! :destroy, publication
        if publication.shared_type?
          ::MailerService.call(:shared_story_deleted, params: { publication: publication, user: current_user })
          ::MailerService.call(:shared_story_deleted_owner, params: { publication: publication, user: current_user })
        end
        publication.destroy!

        response_service.render_no_content
      end

      private

      def filtered_publications
        @filtered_publications ||= ::PublicationFilter.call(
          publications: all_publications,
          params: publication_params,
          current_user: current_user,
          includes: [
            :appreciations,
            { kinship: { avatar_attachment: :blob } },
            { family: { cover_attachment: :blob } },
            { story: [
              :not_private_publications,
              :published_publications,
              :sections,
              :families,
              :user,
              { taggings: :tag },
              { cover_attachment: { blob: :variant_records } }
            ] }
          ]
        )
      end

      # https://github.com/ledermann/unread#getting-readunread-stats-through-a-relationship
      def unread_list(publications)
        Story.where(id: publications.pluck(:story_id)).with_read_marks_for(current_user).filter_map do |story|
          story.id if story.unread?(current_user)
        end
      end

      def set_headers
        tags = ActsAsTaggableOn::Tag
               .joins(:taggings)
               .where(taggings: { taggable_type: 'Story', taggable_id: all_publications&.pluck(:story_id) })
               .distinct
               .order(updated_at: :desc)
        response.headers['All-Stories-Categories'] = tags.map do |tag|
          { text: tag.name, number: tag.taggings_count }
        end.to_json
      end

      def all_publications
        @all_publications ||= Publication.accessible_by(current_ability).includes(:story)
      end

      def publication
        @publication ||= Publication.includes(:family, :story).find(params[:id])
      end

      def publication_params
        params.permit(
          :family_id,
          :publication_visibility,
          :author_id,
          :query,
          :sort_by,
          :sort_direction,
          categories: []
        )
      end

      def create_params
        params.require(:publication).permit(
          :id,
          :share_type,
          publish_on: {},
          families_ids: []
        )
      end
    end
  end
end
