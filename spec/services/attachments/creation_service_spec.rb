require 'spec_helper'

describe Attachments::CreationService do
  subject(:result) { described_class.call(vault: vault, params: params, current_user: current_user) }

  let(:user) { create :user }
  let(:family_member) { create :user }
  let(:family) { create :family, users: [user, family_member] }
  let(:image_blob_1) { create_file_blob }
  let(:params) { { box_id: box_id, files: [{ signed_id: image_blob_1.signed_id, title: 'some title' }] } }
  let(:box_id) { nil }
  let(:current_user) { user.reload }

  context 'with family vault' do
    let(:vault) { family.vault }

    it 'creates file in family vault' do
      expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
      expect(result.first.user).to eq(user)
      expect(result.first.family).to eq(family)
      expect(result.first.record).to eq(vault)
      expect(result.first.box).to eq(nil)
      expect(result.first.title).to eq('some title')
    end

    context 'with box' do
      let(:box) { create :box, vault: vault }
      let(:box_id) { box.id }

      it 'creates file in box' do
        expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
        expect(result.first.user).to eq(user)
        expect(result.first.family).to eq(family)
        expect(result.first.record).to eq(vault)
        expect(result.first.box).to eq(box)
      end
    end
  end

  context 'with user vault' do
    let(:vault) { user.vault }

    it 'creates file in user vault' do
      expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
      expect(result.first.user).to eq(user)
      expect(result.first.family).to eq(nil)
      expect(result.first.record).to eq(vault)
      expect(result.first.box).to eq(nil)
    end

    context 'with box' do
      let(:box) { create :box, vault: vault }
      let(:box_id) { box.id }

      it 'creates file in box' do
        expect { result }.to change(ActiveStorage::Attachment, :count).by(1)
        expect(result.first.user).to eq(user)
        expect(result.first.family).to eq(nil)
        expect(result.first.record).to eq(vault)
        expect(result.first.box).to eq(box)
      end
    end
  end
end
