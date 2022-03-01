# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  body             :text             not null
#  commentable_id   :integer          not null
#  commentable_type :string           not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CommentSerializer < BaseSerializer
  set_id :uid
  set_type :comment

  has_many_encoded :comments

  attributes(
    :body,
    :created_at,
    :user_id,
    :commentable_type,
    :comments_count
  )

  attribute :commentable_id do |object|
    # TODO-UUID: use attr without a block after migration to UUID in Section and Publication
    object.commentable.respond_to?(:uid) ? object.commentable.uid : object.commentable_id
  end

  attribute :user_name do |object|
    object.user.kinships.find_by(family: object.publication.family)&.nickname
  end

  attribute :user_avatar_url do |object|
    object.user.kinships.find_by(family: object.publication.family)&.avatar_url(size: :thumb)
  end
end
