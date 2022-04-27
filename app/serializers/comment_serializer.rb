class CommentSerializer < BaseSerializer
  set_type :comment

  def initialize(*args)
    super
    @family = nil
  end

  has_many :comments do |comment, params|
    if comment.top_commentable.instance_of?(Publication) && comment.top_commentable.personal_type? &&
       comment.top_commentable.story.user_id != params[:current_user].id
      comment.comments.where(user_id: [params[:current_user].id, comment.top_commentable.story.user_id])
    else
      comment.comments
    end
  end

  attributes(
    :body,
    :created_at,
    :user_id,
    :commentable_id,
    :commentable_type,
    :comments_count
  )

  attribute :family do |object|
    @family = case object.top_commentable_type
              when 'Publication', 'Kinship' then object.top_commentable.family
              when 'Family' then object.top_commentable
              end
  end

  attribute family_id: @family&.id

  attribute :user_name do |object|
    object.user.all_kinships.find_by(family: @family)&.nickname
  end

  attribute :user_avatar_url do |object|
    object.user.all_kinships.find_by(family: @family)&.avatar_url(size: :thumb)
  end
end
