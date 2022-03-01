# == Schema Information
#
# Table name: chapters
#
#  id                :bigint     not null, primary key
#  chapterable_id    :integer    not null
#  chapterable_type  :string     not null
#  position          :integer    not null
#  title             :string
#  body              :text
#  media_type        :string      not null
#  created_at        :datetime    not null
#  updated_at        :datetime    not null
#

class ChapterSerializer < BaseSerializer
  attributes(
    :title,
    :body,
    :media_type,
    :position,
    :created_at,
    :updated_at
  )

  attribute :rich_body do |object|
    object.rich_body.attributes.merge(
      Concern::SerializeRichBody.attributes_hash(object.rich_body.body)
    )
  end

  attribute :author_avatar_url do |object|
    case object.chapterable_type
    when 'Family'
      object.author.kinships.find_by(family: object.chapterable)&.avatar_url(size: :thumb)
      # when 'Kinship'
      #   object.chapterable.avatar_url(size: :thumb)
    end
  end

  attribute :author_name do |object|
    case object.chapterable_type
    when 'Family'
      object.author.kinships.find_by(family: object.chapterable)&.nickname
      # when 'Kinship'
      #   object.chapterable.nickname
    end
  end
end
