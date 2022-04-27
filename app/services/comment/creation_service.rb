class Comment
  class CreationService < ApplicationService
    def initialize(current_user, params, top_commentable: nil)
      @current_user = current_user
      @top_commentable = top_commentable
      @params = params
    end

    def call
      @comment = current_user.comments.new(body: params[:body])
      @comment.commentable = commentable
      @comment.top_commentable = top_commentable

      notify_recipients if @comment.save
      @comment
    end

    private

    attr_reader :current_user, :params, :top_commentable

    def commentable
      params[:commentable_type].constantize.find_by(id: params[:commentable_id])
    end

    def notify_recipients
      return unless top_commentable.instance_of?(Publication)

      recipients.each do |recipient|
        ::MailerService.call(
          :comment_created,
          params: {
            recipient: recipient,
            comment: @comment,
            publication: top_commentable,
            commentable: commentable
          }
        )
      end
    end

    def recipients
      commentable = @comment.commentable

      users_ids = case commentable
                  when Publication, Section
                    ids = commentable.commenters.ids +
                          commentable.story.contributors.ids +
                          [commentable.story.user_id]
                    ids.uniq!
                    ids.delete(current_user.id)
                    ids
                  when Comment
                    [commentable.user_id]
                  end
      # send mails only to active members
      User.includes(:kinships).where(id: users_ids, kinships: { family_id: top_commentable.family_id })
    end
  end
end
