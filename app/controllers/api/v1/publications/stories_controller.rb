module Api
  module V1
    module Publications
      class StoriesController < BaseController
        def chapter_links
          authorize! :read, publication
          response_service.render(StorySerializer, publication.story, options: { include: includes })
        end

        def update
          authorize! :update, publication
          story = ::Stories::UpdatingService.call(publication.story, story_params)
          story.mark_as_read! for: current_user
          response_service.render(StorySerializer, story)
        end

        def destroy
          authorize! :destroy, publication
          if publication.community_type?
            ::MailerService.call(:community_story_deleted, params: { publication: publication, user: current_user })
          end
          publication.story.destroy!
          response_service.render_no_content
        end

        def duplicate
          authorize! :create, publication
          story = ::Stories::DuplicationService.call(publication.story, user: current_user, publication: publication)
          story.mark_as_read! for: current_user
          response_service.render(StorySerializer, story)
        end

        def notify
          authorize! :read, publication
          publication.story.publications.not_private_type.each do |publication|
            ::Stories::NotificationService.notify_contribution(publication, current_user, params[:changed_attr])
          end

          response_service.render_no_content
        end

        protected

        def publication
          @publication ||= Publication.find(params[:publication_id])
        end

        def story_params
          params.require(:story).permit(
            :cover,
            :title,
            :description,
            :start_year,
            :start_month,
            :start_day,
            :end_year,
            :end_month,
            :end_day,
            :is_range,
            categories: []
          )
        end
      end
    end
  end
end
