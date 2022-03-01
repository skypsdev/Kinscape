# == Schema Information
#
# Table name: publications
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  family_id   :integer          not null
#  story_id    :integer          not null
#  publish_on  :date
#  notified_at :datetime
#

class PublicationSerializer < BaseSerializer
  set_type :publication
  set_id :id

  belongs_to_encoded :family
  belongs_to_encoded :story do |_object, params|
    { params: params.merge(publication_id: object.id) }
  end
  has_many_encoded :comments
  has_many_encoded :all_comments

  attributes(
    :appreciations_count,
    :publish_on,
    :comments_count,
    :all_comments_count,
    :share_type
  )

  attribute :appreciation_id do |object, params|
    object.appreciations.find { |appreciation| appreciation.user_id == params[:current_user].id }&.id
  end

  attribute :unread do |object, params|
    object.story_id.in?(params[:unread]) if params[:unread].present?
  end

  attribute :user_name do |object|
    object.story.user.kinships.find_by(family: object.family)&.nickname
  end

  attribute :user_avatar do |object|
    object.story.user.kinships.find_by(family: object.family)&.avatar_url(size: :thumb)
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
