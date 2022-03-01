# == Schema Information
#
# Table name: sections
#
#  id         :integer          not null, primary key
#  body       :text
#  story_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  media_type :string           not null
#  position   :integer          not null
#  author_id  :integer
#  title      :string
#  aws        :boolean
#

FactoryBot.define do
  factory :text_section, class: 'Section' do
    story
    title { 'Type Chapter Heading Here' }
    rich_body { '<p>This is a text section<p>' }
    media_type { 'text' }
    after(:build) do |section|
      section.author ||= section.story.user
    end
  end

  factory :text_section_with_header, class: 'Section' do
    story
    title { 'With a header' }
    rich_body { '><p>This is a text section<p>' }
    media_type { 'text' }
    after(:build) do |section|
      section.author ||= section.story.user
    end
  end

  factory :section do
    story

    body { 'Section body' }
    media_type { 'image' }

    after(:build) do |section|
      section.author ||= section.story.user
      section.media_files << build(:media_file) if section.attachments.empty?
    end
  end
end
