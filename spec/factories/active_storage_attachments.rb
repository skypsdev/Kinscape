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
  factory :active_storage_attachment, class: 'ActiveStorage::Attachment' do
    association :record, factory: :vault
    name { 'files' }
  end
end
