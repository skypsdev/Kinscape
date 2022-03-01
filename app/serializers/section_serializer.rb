# == Schema Information
#
# Table name: sections
#
#  id         :bigint           not null, primary key
#  body       :text
#  story_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  media_type :string           not null
#  position   :integer          not null
#  author_id  :integer
#

class SectionSerializer < BaseSerializer
  set_id :id

  attributes(
    :body,
    :media_type,
    :position,
    :created_at,
    :updated_at,
    :title,
    :comments_count
  )

  has_many :comments

  attribute :story_id do |object|
    object.story&.uid
  end

  attribute :rich_body do |object|
    object.rich_body.attributes.merge(
      Concern::SerializeRichBody.attributes_hash(object.rich_body.body)
    )
  end

  attribute :is_author do |object, params|
    object.author_id == params[:current_user].id
  end

  attribute :author_avatar_url do |object|
    object.author.kinships.find_by(family: object.story.publications.first&.family)&.avatar_url(size: :thumb)
  end

  attribute :author_name do |object|
    object.author.kinships.find_by(family: object.story.publications.first&.family)&.nickname
  end
end
