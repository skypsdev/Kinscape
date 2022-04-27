FactoryBot.define do
  factory :section do
    story

    body { 'Section body' }

    after(:build) do |section|
      section.author ||= section.story.user
    end
  end
end
