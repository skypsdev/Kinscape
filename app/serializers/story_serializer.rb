class StorySerializer < BaseSerializer
  set_type :story

  attributes(
    :date,
    :description,
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
  has_many :families
  has_many :publications, object_method_name: :not_private_publications

  attribute :unread do |object, params|
    object.id.in?(params[:unread]) if params[:unread].present?
  end

  attribute :published do |object|
    object.published_publications.present?
  end

  attribute :links do |object|
    object.sections.pluck(:id, :title, :position).map do |arr|
      { id: arr[0], title: arr[1], position: arr[2] }
    end
  end

  attribute :categories, &:category_list
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
