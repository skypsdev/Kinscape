require 'spec_helper'

describe Attachments::MovingService do
  subject(:result) { described_class.call(vault: user.vault, attachments: attachments, params: params) }

  let(:user) { create :user }
  let(:box) { create :box, vault: user.vault }
  let(:source_box) { create :box, vault: user.vault }
  let(:image_blob) { create_file_blob }
  let(:image_blob_2) { create_file_blob }
  let(:attachment) { create :active_storage_attachment, record: user.vault, box: source_box, blob: image_blob }
  let(:attachment_2) { create :active_storage_attachment, record: user.vault, box: source_box, blob: image_blob_2 }
  let!(:attachments) { ActiveStorage::Attachment.where(id: [attachment.id, attachment_2.id], record: user.vault) }
  let(:params) { { box_id: box_id, ids: [attachment.id, attachment_2.id] } }
  let(:box_id) { box.id }

  context 'when moving to root of vault' do
    let(:box_id) { nil }

    it 'changes box_id to nil' do
      expect { result }.to change(source_box.attachments, :count).by(-2)
    end
  end

  context 'when attachments from different vaults' do
    let(:image_blob) { create_file_blob }
    let(:image_blob_2) { create_file_blob }
    let(:attachment) { create :active_storage_attachment, blob: image_blob }
    let(:attachment_2) { create :active_storage_attachment, blob: image_blob_2 }

    it 'raises error' do
      expect { result }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when attachments moved successfully' do
    it 'moves all attachments to box' do
      expect { result }.to change(box.attachments, :count)
        .by(2)
        .and change(source_box.attachments, :count)
        .by(-2)
      expect(box.attachments).to contain_exactly(attachment, attachment_2)
    end
  end
end
