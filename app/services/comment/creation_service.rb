class Comment
  class CreationService < ApplicationService
    def initialize(current_user, publication, params)
      @current_user = current_user
      @publication = publication
      @params = params
    end

    def call
      @comment = current_user.comments.new(body: params[:body], publication: publication)
      @comment.commentable = commentable
      notify_recipients if @comment.save
      @comment
    end

    private

    attr_reader :current_user, :params, :publication

    def commentable
      # TODO-UUID: remove it after migration to UUID in Section and Publication
      # and pass params commentable_type nad commentable_id directly to new comment
      if params[:commentable_type] == 'Comment'
        Comment.find_by_uid(params[:commentable_id])
      else
        params[:commentable_type].constantize.find_by(id: params[:commentable_id])
      end
    end

    def notify_recipients
      recipients.each do |recipient|
        ::MailerService.call(
          :comment_created,
          params: {
            recipient: recipient,
            comment: @comment,
            publication: publication
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
      User.includes(:kinships).where(id: users_ids, kinships: { family_id: publication.family_id })
    end
  end
end
