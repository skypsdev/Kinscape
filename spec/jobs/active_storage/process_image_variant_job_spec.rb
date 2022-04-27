require 'spec_helper'

RSpec.describe ActiveStorage::ProcessImageVariantJob, type: :job do
  subject(:job) { described_class.perform_now(attachment.id) }

  let(:image_blob) { create_file_blob }
  let(:story) { create :story, cover: image_blob }
  let!(:attachment) { story.cover }

  it 'create variant record' do
    expect { job }.to change { ActiveStorage::VariantRecord.count }.by(1)
  end
end
