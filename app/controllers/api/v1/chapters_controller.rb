module Api
  module V1
    class ChaptersController < BaseController
      def index
        authorize! :read, object
        chapters = object.chapters.order(position: :asc)
        response_service.render_collection(ChapterSerializer, chapters)
      end

      def create
        authorize! :manage, object
        chapter = ::Chapters::CreationService.call(object, chapter_params, current_user)
        response_service.render(ChapterSerializer, chapter)
      end

      def update
        authorize! :update, chapter
        chapter_updated = ::Chapters::UpdatingService.call(chapter, chapter_params)

        response_service.render(ChapterSerializer, chapter_updated)
      end

      def destroy
        authorize! :destroy, chapter
        chapter.destroy
        object.touch

        response_service.render_no_content
      end

      def table_content_list
        # TODO: remove that endpoint
        authorize! :read, object
        response_service.render("#{params[:object_type]}Serializer".constantize, object, options: { include: includes })
      end

      private

      def chapter_params
        params.permit(
          :position,
          :title,
          rich_body: [:body]
        )
      end

      def chapter
        @chapter ||= object.chapters.find(params[:id])
      end

      def object
        @object ||= case params[:object_type]
                    when 'Family'
                      if params[:showcase].present?
                        families = User.find_by(email: Showcase::USER_EMAIL).families
                        families.find_by(name: Showcase::FAMILY_NAME)
                      else
                        Family.find(params[:object_id])
                      end
                    when 'Kinship'
                      Kinship.find(params[:object_id])
                    end
      end
    end
  end
end
