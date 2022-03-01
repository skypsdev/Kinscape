# == Schema Information
#
# Table name: stories
#
#  id                  :bigint           not null, primary key
#  title               :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  date                :string           default(""), not null
#  description         :text             default(""), not null
#  user_id             :integer          not null
#  tags                :string           default([]), is an Array
#  cover_image_id      :integer
#  start_year          :string
#  start_month         :string
#  start_day           :string
#  end_year            :string
#  end_month           :string
#  end_day             :string
#  is_range            :boolean          default(FALSE)
#  date_as_text        :string           default(""), not null
#  comments_count      :integer
#  appreciations_count :bigint           default(0)
#

require 'filestack_config'

class StorySerializer < BaseSerializer
  set_type :story
  set_id :uid

  attributes(
    :date,
    :description,
    :categories,
    :title,
    :start_year,
    :start_month,
    :start_day,
    :end_year,
    :end_month,
    :end_day,
    :user_id,
    :is_range,
    :date_as_text,
    :contributors_count,
    :sections_count,
    :created_at,
    :updated_at
  )

  has_many :sections
  has_many_encoded :families
  has_many :publications, object_method_name: :not_private_publications

  attribute :unread do |object, params|
    object.id.in?(params[:unread]) if params[:unread].present?
  end

  attribute :published do |object|
    object.not_private_publications.published.present?
  end

  attribute :links do |object|
    object.sections.pluck(:id, :title, :position).map do |arr|
      { id: arr[0], title: arr[1], position: arr[2] }
    end
  end

  attribute :is_time_capsule, &:time_capsule?
  attribute :time_capsule_released, &:time_capsule_released?

  attribute :publish_on do |object|
    object.time_capsule&.publish_on
  end

  attribute :cover_url do |object|
    object.cover_url(size: :medium)
  end

  attribute :full_size_cover_url, &:cover_url
end
