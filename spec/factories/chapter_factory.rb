FactoryBot.define do
  factory :chapter_family, class: 'Chapter' do
    association :chapterable, factory: :family
    association :author, factory: :user
    title { 'With a family header' }
    rich_body { '><p>This is a text chapter<p>' }
  end

  factory :chapter_kinship, class: 'Chapter' do
    association :chapterable, factory: :kinship
    association :author, factory: :user
    title { 'With a kinship header' }
    rich_body { '><p>This is a text chapter<p>' }
  end
end
