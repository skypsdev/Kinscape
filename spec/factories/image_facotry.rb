# == Schema Information
#
# Table name: media_files
#
#  id             :bigint           not null, primary key
#  mimetype       :string
#  url            :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  filename       :text             default(""), not null
#  key            :string           default(""), not null
#  type           :string           not null
#  height         :integer
#  width          :integer
#  converted_urls :hstore
#  user_id        :integer
#  size           :integer
#  title          :string
#

FactoryBot.define do
  factory :image do
    mimetype { 'image/jpeg' }
    sequence(:url) { |n| "https://placehold.it/#{n}x" }
    sequence(:filename) { |n| "Filename #{n}x" }
    converted_urls { { 'collage' => 'https://placehold.it/30x' } }
    type { 'Image' }
    height { 800 }
    width { 800 }
    size { 1000 }
  end

  factory :avatar, class: 'Avatar', parent: :image do
    type { 'Avatar' }
    converted_urls do
      {
        'small' => 'https://placehold.it/10x',
        'medium' => 'https://placehold.it/20x',
        'large' => 'https://placehold.it/30x'
      }
    end
  end
end
