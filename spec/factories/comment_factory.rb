FactoryBot.define do
  factory :comment do
    body { 'Hello world' }
    association :commentable, factory: :publication
    user
    association :top_commentable, factory: :publication
  end
end
