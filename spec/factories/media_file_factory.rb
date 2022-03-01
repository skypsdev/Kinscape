# == Schema Information
#
# Table name: media_files
#
#  id             :integer          not null, primary key
#  mimetype       :string
#  url            :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  filename       :text             default(""), not null
#  key            :string           default(""), not null
#  type           :string
#  height         :integer
#  width          :integer
#  converted_urls :hstore
#  user_id        :integer
#  size           :integer
#  title          :string
#

FactoryBot.define do
  factory :media_file do
    sequence(:filename) { |n| "File name#{n}" }
    sequence(:url)      { |n| "https://placehold.it/#{n}x" }
    key { 'key' }
    size { 1000 }
    user
  end

  factory :document_media_file, parent: :media_file, class: 'Document' do
    sequence(:filename) { |n| "File name#{n}.pdf" }
    mimetype { 'application/pdf' }
    type { 'Document' }
    size { 1000 }
  end

  factory :audio_media_file, parent: :media_file, class: 'Audio' do
    sequence(:filename) { |n| "File name#{n}.mp3" }
    mimetype { 'audio/mp3' }
    type { 'Audio' }
    size { 1000 }
  end

  factory :video_media_file, parent: :media_file, class: 'Video' do
    sequence(:filename) { |n| "File name#{n}.mp4" }
    mimetype { 'video/mp4' }
    type { 'Video' }
    size { 1000 }
  end

  factory :image_media_file, parent: :media_file, class: 'Image' do
    sequence(:filename) { |n| "File name#{n}.jpg" }
    mimetype { 'image/jpeg' }
    type { 'Image' }
    size { 1000 }
  end
end
