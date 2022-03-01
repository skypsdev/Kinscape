require 'spec_helper'

RSpec.describe ProcessImageVariantJob, type: :job do
  subject(:job) { described_class.perform_now(story, attachment_name, sizes) }

  let(:image_blob) { create_file_blob }
  let(:story) { create :story, cover: image_blob }
  let(:attachment_name) { :cover }
  let(:sizes) { [:medium, :thumb] }

  it 'create variant record' do
    expect { job }.to change { ActiveStorage::VariantRecord.count }.by(2)
  end
end
