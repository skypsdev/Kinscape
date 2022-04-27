module Api
  module V1
    class CommentsController < BaseController
      def create
        authorize! :create, Comment
        comment = Comment::CreationService.call(current_user, comment_params, top_commentable: top_commentable)
        response_service.render(CommentSerializer, comment)
      end

      def destroy
        comment = Comment.find(params[:id])
        authorize! :destroy, comment
        comment.destroy
        response_service.render_no_content
      end

      private

      def top_commentable
        case params[:parent][:parent_type]
        when 'Publication'
          @publication ||= Publication.accessible_by(current_ability).find(params[:parent][:parent_id])
        when 'Family'
          @family ||= Family.accessible_by(current_ability).find(params[:parent][:parent_id])
        when 'Kinship'
          @kinship ||= Kinship.accessible_by(current_ability).find(params[:parent][:parent_id])
        end
      end

      def comment_params
        params.require(:comment).permit(:body, :commentable_type, :commentable_id)
      end
    end
  end
end
