require 'spec_helper'

describe Attachments::CopyingService do
  subject(:result) { service.call }

  let(:service) do
    described_class.new(
      vault: vault,
      new_vault: new_vault,
      current_user: current_user,
      attachments: attachments,
      params: { ids: attachments.map(&:id), box_id: box_id }
    )
  end

  let(:box_id) { nil }

  let(:jamie) { create :user, first_name: 'Jamie', last_name: 'Hyneman' }
  let(:adam) { create :user, first_name: 'Adam', last_name: 'Savage' }

  let(:the_hynemans) { create :family, users: [jamie] }
  let(:mythbusters) { create :family, users: [jamie, adam] }

  let(:mythbusters_vault) { mythbusters.vault }
  let(:mythbusters_box) { create :box, vault: mythbusters_vault }

  let(:jamie_blob_1) { create_file_blob }
  let(:jamie_blob_2) { create_file_blob(filename: 'image_2.png') }
  let(:adam_blob_1) { create_file_blob }
  let(:adam_blob_2) { create_file_blob(filename: 'image_2.png') }

  let(:jamie_attachment_1) { create :active_storage_attachment, record: jamie.vault, blob: jamie_blob_1 }
  let(:jamie_attachment_2) { create :active_storage_attachment, record: jamie.vault, blob: jamie_blob_2 }
  let(:adam_attachment_1) { create :active_storage_attachment, record: adam.vault, blob: adam_blob_1 }
  let(:adam_attachment_2) { create :active_storage_attachment, record: adam.vault, blob: adam_blob_2 }

  context 'Jamie shares files with his Mythbusters family' do
    let(:vault) { jamie.vault }
    let(:new_vault) { mythbusters_vault }
    let(:current_user) { jamie }
    let(:attachments) { [jamie_attachment_1, jamie_attachment_2] }

    it 'adds files to the Mythbusters vault' do
      expect { result }.to change { mythbusters_vault.reload.files.size }.by(2)
    end

    context 'Jamie shares files with his Mythbusters family in box' do
      let(:box_id) { mythbusters_box.id }

      it 'adds files to the Mythbusters vault and box' do
        expect { result }.to change { mythbusters_vault.reload.files.size }
          .by(2)
          .and change { mythbusters_box.reload.attachments.count }
          .by(2)
      end
    end
  end

  context "attachments ain't from the same vault" do
    let(:vault) { jamie.vault }
    let(:new_vault) { mythbusters_vault }
    let(:current_user) { jamie }
    let(:attachments) { [jamie_attachment_1, adam_attachment_1] }

    it 'returns :different_vaults error' do
      expect { result }.to avoid_changing { mythbusters_vault.reload.files.size }
        .and(avoid_changing { mythbusters_box.reload.attachments.count })
      expect(service.errors).to eq ['Attachments should belong to the same vault.']
    end
  end

  context 'trying to share file to the same vault' do
    let(:vault) { jamie.vault }
    let(:new_vault) { jamie.vault }
    let(:current_user) { jamie }
    let(:attachments) { [jamie_attachment_1] }

    before { jamie_attachment_1 }

    it 'copies files' do
      expect { result }.to change { vault.reload.files.size }
        .by(1)
      expect(new_vault.files.attachments.last).to have_attributes(
        copy_number: 1,
        title: "#{jamie_attachment_1.filename.base}(1)"
      )
    end
  end

  context 'file already exist in the vault' do
    let(:vault) { jamie.vault }
    let(:new_vault) { mythbusters_vault }
    let(:current_user) { jamie }
    let(:attachments) { [jamie_attachment_1, jamie_attachment_2] }

    let(:existing_attachment) do
      described_class.new(
        vault: vault,
        new_vault: new_vault,
        current_user: current_user,
        attachments: [jamie_attachment_1],
        params: { ids: [jamie_attachment_1.id], box_id: box_id }
      ).call.first
    end

    it 'shares same files to family vault' do
      expect { result }.to change { mythbusters_vault.reload.files.size }
        .by(2)
        .and avoid_changing { existing_attachment.reload.title }
      expect(existing_attachment.title).to eq(nil)
    end
  end

  context 'trying to share files from family to family' do
    let(:vault) { the_hynemans }
    let(:new_vault) { mythbusters_vault }
    let(:current_user) { jamie }
    let(:attachments) { [jamie_attachment_1, jamie_attachment_2] }
    let(:jamie_attachment_1) { create :active_storage_attachment, record: the_hynemans, blob: jamie_blob_1 }
    let(:jamie_attachment_2) { create :active_storage_attachment, record: the_hynemans, blob: jamie_blob_2 }

    it 'shares files to another family vault' do
      expect { result }.to change { mythbusters_vault.reload.files.size }.by(2)
    end
  end
end
