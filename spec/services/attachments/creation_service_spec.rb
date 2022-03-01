require 'spec_helper'

describe Attachments::CreationService do
  subject(:result) { described_class.call(vault: vault, params: params, current_user: current_user) }

  let(:user) { create :user }
  let(:family_member) { create :user }
  let(:family) { create :family, users: [user, family_member] }
  let!(:family_vault) { create :vault, owner: family }
  let(:image_blob_1) { create_file_blob }
  let(:params) { { box_id: box_id, file: image_blob_1.signed_id } }
  let(:box_id) { nil }
  let(:current_user) { user.reload }

  context 'with family vault' do
    let(:vault) { family_vault }

    it 'creates file in family vault' do
      expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
      expect(result.user).to eq(user)
      expect(result.family).to eq(family)
      expect(result.record).to eq(vault)
      expect(result.box).to eq(nil)
    end

    context 'with box' do
      let(:box) { create :box, vault: vault }
      let(:box_id) { box.id }

      it 'creates file in box' do
        expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
        expect(result.user).to eq(user)
        expect(result.family).to eq(family)
        expect(result.record).to eq(vault)
        expect(result.box).to eq(box)
      end
    end
  end

  context 'with user vault' do
    let(:vault) { user.vault }

    it 'creates file in user vault' do
      expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
      expect(result.user).to eq(user)
      expect(result.family).to eq(nil)
      expect(result.record).to eq(vault)
      expect(result.box).to eq(nil)
    end

    context 'with box' do
      let(:box) { create :box, vault: vault }
      let(:box_id) { box.id }

      it 'creates file in box' do
        expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
        expect(result.user).to eq(user)
        expect(result.family).to eq(nil)
        expect(result.record).to eq(vault)
        expect(result.box).to eq(box)
      end
    end
  end
end
