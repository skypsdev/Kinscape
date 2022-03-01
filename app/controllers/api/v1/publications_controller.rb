module Api
  module V1
    class PublicationsController < BaseController
      def index
        authorize! :read, Publication
        @pagy, records = pagy(filtered_publications, items: 10)
        options = {
          include: [:family, :story, :comments],
          params: { unread: unread_list(filtered_publications) },
          fields: {
            family: [:name],
            publication: PublicationSerializer.attributes_to_serialize.keys.excluding(:all_publications) +
                         [:family, :story, :comments],
            story: StorySerializer.attributes_to_serialize.keys.excluding(:full_size_cover_url, :links)
          }
        }
        set_headers
        response_service.render_collection(PublicationSerializer, records, options: options)
      end

      def show
        includes = [:family, :story, :comments, :all_comments]
        publication = Publication.includes(includes).find(params[:id])
        authorize! :read, publication
        publication.story.mark_as_read! for: current_user
        options = { include: [:all_comments, :story, :'story.publications', :'story.families'] }
        set_headers
        response_service.render(PublicationSerializer, publication, options: options)
      end

      def create
        authorize! :update, story
        publications = ::Publications::CreationService.call(story, current_user, create_params)
        response_service.render_collection(PublicationSerializer, publications)
      rescue Date::Error
        # TODO: move it to service and return as an error in AR
        response_service.render_forbidden
      end

      def destroy
        publication = story.publications.find params[:id]
        authorize! :destroy, publication
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
            :family,
            :appreciations,
            :comments,
            { story: [
              :publications,
              :not_private_publications,
              :sections,
              :families,
              { cover_attachment: { blob: :variant_records } },
              { user: :avatar }
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
        @story_headers = {
          unfiltered_count: all_publications.size,
          all_categories: all_publications.pluck(:'stories.categories').flatten.tally
        }
      end

      def all_publications
        @all_publications ||= Publication.accessible_by(current_ability).includes(:story)
      end

      def story
        @story ||= current_user.stories.find_by_uid!(params[:story_id])
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
          :share_type,
          publish_on: {},
          families_ids: []
        )
      end
    end
  end
end
