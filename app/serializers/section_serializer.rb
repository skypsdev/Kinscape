class SectionSerializer < BaseSerializer
  set_id :id

  attributes(
    :body,
    :position,
    :created_at,
    :updated_at,
    :title,
    :author_id,
    :appreciations_count,
    :comments_count
  )

  has_many :comments

  attribute :appreciation_id do |object, params|
    object.appreciations.find { |appreciation| appreciation.user_id == params[:current_user].id }&.id
  end

  attribute :story_id do |object|
    object.story.id
  end

  attribute :rich_body do |object|
    object.rich_body.attributes.merge(
      Concern::SerializeRichBody.attributes_hash(object.rich_body.body)
    )
  end

  attribute :author_avatar_url do |object|
    object.kinship&.avatar_url(size: :thumb)
  end

  attribute :author_name do |object|
    object.kinship&.nickname
  end
end
