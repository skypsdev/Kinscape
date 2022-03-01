# == Schema Information
#
# Table name: attachments
#
#  id               :integer          not null, primary key
#  media_file_id    :integer          not null
#  containable_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  containable_type :string           not null
#  position         :integer
#  comments_count   :integer
#  box_id           :integer
#  uuid             :bigint
#

FactoryBot.define do
  factory :attachment do
    association :media_file, factory: :image
    association :containable, factory: :text_section

    trait :document do
      association :media_file, factory: :document_media_file
    end

    trait :audio do
      association :media_file, factory: :audio_media_file
    end

    trait :video do
      association :media_file, factory: :video_media_file
    end
  end
end
