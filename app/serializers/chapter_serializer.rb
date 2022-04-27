class ChapterSerializer < BaseSerializer
  attributes(
    :title,
    :body,
    :position,
    :appreciations_count,
    :comments_count,
    :created_at,
    :updated_at
  )

  has_many :comments

  attribute :appreciation_id do |object, params|
    object.appreciations.find { |appreciation| appreciation.user_id == params[:current_user].id }&.id
  end

  attribute :rich_body do |object|
    object.rich_body.attributes.merge(
      Concern::SerializeRichBody.attributes_hash(object.rich_body.body)
    )
  end

  attribute :author_avatar_url do |object|
    case object.chapterable_type
    when 'Family'
      object.kinship&.avatar_url(size: :thumb)
      # when 'Kinship'
      #   object.chapterable.avatar_url(size: :thumb)
    end
  end

  attribute :author_name do |object|
    case object.chapterable_type
    when 'Family'
      object.kinship&.nickname
      # when 'Kinship'
      #   object.chapterable.nickname
    end
  end
end
