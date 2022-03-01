# == Schema Information
#
# Table name: vaults
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  family_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :bigint
#

require 'spec_helper'

describe Vault, type: :model do
  let(:user)   { create :user }
  let(:family) { create :family, name: 'The Simpsons' }

  describe 'associations' do
    it { is_expected.to belong_to :owner }
    it { is_expected.to have_many :attachments }
    it { is_expected.to have_many :media_files }
  end

  describe '#name' do
    it 'returns "My Vault" name of a private vault' do
      vault = build :vault, owner: user

      expect(vault.name).to eq 'My Vault'
    end

    it 'return name of a family vault' do
      vault = build :vault, owner: family

      expect(vault.name).to eq 'The Simpsons Vault'
    end
  end

  describe '#cover_url' do
    it 'returns users avatar url when vault is private' do
      vault = build :vault, owner: user

      expect(vault.cover_url).to eq user.avatar_url(size: :medium)
    end

    it 'returns family cover url of family vault' do
      vault = build :vault, owner: family

      expect(vault.cover_url).to eq family.cover_image_url(size: :medium)
    end
  end

  describe '#boxes' do
    let!(:vault) { create :vault }

    let!(:box_2) { create :box, vault: vault, created_at: Time.zone.now }
    let!(:box_1) { create :box, vault: vault, created_at: 1.day.ago }

    it 'orders boxes by created_at' do
      expect(vault.boxes[0]).to eq box_1
      expect(vault.boxes[1]).to eq box_2
    end
  end
end
