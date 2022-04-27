require 'spec_helper'

RSpec.describe ActiveStorage::Attachment, type: :model do
  subject(:model) { described_class.new }

  describe 'associations' do
    it { is_expected.to belong_to(:box).optional }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:family).optional }
  end

  describe 'callbacks' do
    let(:user) { create :user }
    let(:blob) { create_file_blob(user: user, filename: 'mpeg4.wmv') }

    it do
      model.assign_attributes(blob: blob, record: user.vault, name: 'vault')
      expect { model.save }.to have_enqueued_job(ActiveStorage::ConvertAudioVideoJob)
    end
  end
end
