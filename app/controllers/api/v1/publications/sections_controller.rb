module Api
  module V1
    module Publications
      class SectionsController < BaseController
        def index
          authorize! :read, publication
          @pagy, sections = pagy(
            Section.includes(:author, story: :families)
                   .where(story_id: story.id)
                   .references(:story)
                   .with_rich_text_rich_body_and_embeds
                   .order(:position),
            items: params[:per_page] || 12
          )
          response_service.render_collection(SectionSerializer, sections)
        end

        def create
          authorize! :collaborate, publication
          section = ::Sections::CreationService.call(publication, current_user, section_params)
          response_service.render(SectionSerializer, section)
        end

        def update
          authorize! :update, section
          section_updated = ::Sections::UpdatingService.call(section, current_user, section_params)
          response_service.render(SectionSerializer, section_updated)
        end

        def destroy
          authorize! :destroy, section
          section.destroy
          story.touch

          response_service.render_no_content
        end

        private

        def section_params
          params.permit(
            :position,
            :title,
            rich_body: [:body]
          )
        end

        def publication
          @publication ||= Publication.find(params[:publication_id])
        end

        def story
          @story ||= publication.story
        end

        def section
          @section ||= story.sections.find(params[:id])
        end

        def mark_story_as_read
          @story.reload.mark_as_read! for: current_user
        end
      end
    end
  end
end
