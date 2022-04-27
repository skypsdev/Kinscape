class PublicationSerializer < BaseSerializer
  set_type :publication
  set_id :id

  belongs_to :family
  belongs_to :story
  has_many :all_comments, serializer: CommentSerializer do |publication, params|
    if publication.personal_type? && publication.story.user_id != params[:current_user].id
      publication.all_comments.where(user_id: [params[:current_user].id, publication.story.user_id])
    else
      publication.all_comments
    end
  end

  attributes(
    :appreciations_count,
    :publish_on,
    :comments_count,
    :all_comments_count,
    :share_type
  )

  attribute :family_id do |object|
    object.family&.id
  end

  attribute :appreciation_id do |object, params|
    object.appreciations.find { |appreciation| appreciation.user_id == params[:current_user].id }&.id
  end

  attribute :unread do |object, params|
    object.story_id.in?(params[:unread]) if params[:unread].present?
  end

  attribute :user_name do |object|
    object.kinship&.nickname
  end

  attribute :user_avatar do |object|
    object.kinship&.avatar_url(size: :thumb)
  end

  attribute :can_collaborate do |object, params|
    params[:current_user].can?(:collaborate, object)
  end

  attribute :all_publications do |object|
    publications = if object.family_id?
                     object.family.publications.published
                   else
                     object.user.publications.private_type
                   end
    publications.joins(:story).pluck(:'publications.id', :'stories.title').map do |arr|
      { id: arr[0], title: arr[1] }
    end
  end
end
