FactoryBot.define do
  factory :publication do
    story
    family { create :family, users: [story.user] }
  end
end
