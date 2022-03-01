# == Schema Information
#
# Table name: chapters
#
#  id               :bigint           not null, primary key
#  chapterable_id   :integer
#  chapterable_type :string
#  position         :integer
#  title            :string
#  body             :text
#  media_type       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :chapter_family, class: 'Chapter' do
    association :chapterable, factory: :family
    association :author, factory: :user
    title { 'With a family header' }
    rich_body { '><p>This is a text chapter<p>' }
    media_type { 'text' }

    after(:build) do |chapter|
      chapter.media_files << build(:media_file) if chapter.attachments.empty?
    end
  end

  factory :chapter_kinship, class: 'Chapter' do
    association :chapterable, factory: :kinship
    association :author, factory: :user
    title { 'With a kinship header' }
    rich_body { '><p>This is a text chapter<p>' }
    media_type { 'text' }
    after(:build) do |chapter|
      chapter.media_files << build(:media_file) if chapter.attachments.empty?
    end
  end
end
