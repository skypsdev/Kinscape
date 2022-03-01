require 'spec_helper'

describe AttachmentFilter do
  subject(:result) do
    described_class.call(params: params)
  end

  let(:user) { create :user }
  let(:vault_id) { user.vault.id }

  let(:image_blob1) { create_file_blob(filename: 'image.jpg') }
  let(:image_blob2) { create_file_blob(filename: 'image_2.png') }
  let(:image_blob3) { create_file_blob(filename: 'image_3.png') }
  let(:image_blob4) { create_file_blob(filename: 'image_4.png') }
  let!(:attachment1) { create :active_storage_attachment, record: user.vault, blob: image_blob1 }
  let!(:attachment2) { create :active_storage_attachment, record: user.vault, blob: image_blob2, title: 'summer' }
  let!(:attachment3) { create :active_storage_attachment, record: user.vault, blob: image_blob3 }
  let(:box) { create :box, vault: user.vault }
  let!(:box_attachment) { create :active_storage_attachment, record: user.vault, blob: image_blob4, box: box }

  context 'without any params' do
    let(:params) { { id: vault_id } }

    it do
      expect(result.count).to eq(3)
    end
  end

  context 'with query - result from title' do
    let(:params) { { id: vault_id, query: 'summer' } }

    it do
      expect(result.count).to eq(1)
    end
  end

  context 'with query - result from filename' do
    let(:params) { { id: vault_id, query: 'image' } }

    it do
      expect(result.count).to eq(2)
    end
  end

  context 'with sort' do
    let(:params) { { id: vault_id, sort_by: 'name', sort_direction: 'ASC' } }

    it do
      expect(result).to match_array([attachment3, attachment1, attachment2])
    end
  end

  context 'with box id' do
    let(:params) { { id: vault_id, box_id: box.id } }

    it do
      expect(result.count).to eq(1)
      expect(result.first['id']).to eq(box_attachment.id)
    end
  end

  context 'with all combined' do
    let(:params) do
      {
        id: vault_id,
        sort_by: 'name',
        sort_direction: 'ASC',
        query: 'image'
      }
    end

    it do
      expect(result.count).to eq(2)
    end
  end
end
