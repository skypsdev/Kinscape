FactoryBot.define do
  factory :active_storage_attachment, class: 'ActiveStorage::Attachment' do
    association :record, factory: :vault
    name { 'files' }
  end
end
