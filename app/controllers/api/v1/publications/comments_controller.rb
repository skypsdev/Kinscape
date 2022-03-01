module Api
  module V1
    module Publications
      class CommentsController < BaseController
        def create
          authorize! :create, Comment
          comment = Comment::CreationService.call(current_user, publication, comment_params)
          response_service.render(CommentSerializer, comment)
        end

        def destroy
          comment = Comment.find_by_uid!(params[:id])
          authorize! :destroy, comment
          comment.destroy
          response_service.render_no_content
        end

        private

        def publication
          @publication ||= Publication.accessible_by(current_ability).find(params[:publication_id])
        end

        def comment_params
          params.require(:comment).permit(:body, :commentable_type, :commentable_id)
        end
      end
    end
  end
end
