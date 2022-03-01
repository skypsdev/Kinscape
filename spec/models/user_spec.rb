# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  old_avatar         :string           default(""), not null
#  metadata           :hstore
#  tour_completed     :boolean
#  first_name         :string
#  last_name          :string
#  avatar_id          :integer
#  caretaker_id       :integer
#  title              :string
#  confirmed_at       :datetime
#  admin              :boolean          default(FALSE)
#  stripe_id          :string
#  storage_size       :bigint           default(0)
#  uuid               :bigint
#  ability_all        :boolean          default(TRUE), not null
#

require 'spec_helper'

describe User, type: :model do
  describe 'user validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:families) }
    it { is_expected.to have_many(:stories) }
    it { is_expected.to have_many(:subscriptions) }
    it { is_expected.to have_many(:family_subscriptions) }
    it { is_expected.to have_one(:active_subscription) }
    it { is_expected.to have_one(:active_family_subscription) }
  end

  describe 'role' do
    let(:user) { create :user }
    let(:family) { create :family }

    before { create :kinship, user: user, family: family, role: :guest }

    it { expect(user.role_for(family)).to eq 'guest' }
  end

  describe '#vault' do
    it 'returns user private vault' do
      user   = create :user
      create :family, users: [user]

      expect(user.vault).to be_kind_of(Vault)
    end
  end

  describe '#media_uploads_count' do
    it 'returns count of media uploads' do
      story = create(:story)
      story.sections << create(:section, media_type: 'text')
      story.sections += create_list(:section, 2, media_type: 'image')
      user = create(:user)
      user.stories << story

      expect(user.media_uploads_count).to eq 2
    end
  end

  describe '#name' do
    it 'returns the first and last names' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.name).to eq 'John Doe'
    end
  end

  describe '#create' do
    it 'creates an vault after user is created' do
      user = create :user

      expect(user.vault).to be_present
    end
  end

  describe '#confirm_email' do
    it 'sets confirmed_at value' do
      user = create(
        :user,
        confirmation_token: 'token',
        confirmed_at: nil
      )

      user.confirm_email

      expect(user.confirmed_at).to be_present
    end
  end

  describe 'destroy user with all associations' do
    let(:user)           { create :user }
    let(:another_user)   { create :user }
    let!(:family_1)       { create :family, users: [another_user, user] }
    let!(:family_2)       { create :family, users: [another_user, user] }

    before do
      create :vault, owner: family_2
      create :subscription, user: user
      create :box, vault: user.vault
      create :comment, user: user
      create :story, user: user
    end

    it 'deletes user vaults alongside user' do
      expect { user.reload.destroy }.to change(described_class, :count)
        .by(-1)
        .and change(Vault, :count)
        .by(-1)
        .and change(Story, :count)
        .by(-1)
        .and change(Box, :count)
        .by(-1)
        .and change(Comment, :count)
        .by(-1)
        .and change(Comment, :count)
        .by(-1)
        .and change(Kinship, :count)
        .by(-2)
      # expect(family_vault_2.reload).to be_present
      expect(family_1.reload).to be_present
      expect(family_2.reload).to be_present
    end

    context 'with user as admin' do
      let!(:family_1)       { create :family, users: [user, another_user] }
      let!(:family_2)       { create :family, users: [user, another_user] }

      it 'deletes user vaults alongside user' do
        expect(user.owned_families.size).to eq(2)
        expect { user.destroy }.to raise_error(RuntimeError)
        expect(family_1.reload).to be_present
        expect(family_2.reload).to be_present
      end
    end
  end
  # Temp. remove payment feature
  # describe '#guest?' do
  #   it 'returns nil if the subscription is active' do
  #     subscription = create(:subscription, status: 'active')

  #     expect(subscription.user.guest?).to be nil
  #   end

  #   it 'returns nil if the subscription is not past due' do
  #     subscription = create(:subscription, status: 'trialing')

  #     expect(subscription.user.guest?).to be nil
  #   end

  #   it 'returns true if the subscription is past due' do
  #     subscription = create(:subscription, status: 'past_due')

  #     expect(subscription.user.guest?).to be true
  #   end
  # end

  # describe '#trialing?' do
  #   it 'returns true if the subscription is trialing' do
  #     subscription = create(:subscription, status: 'trialing')

  #     expect(subscription.user.trialing?).to be true
  #   end
  # end

  # describe '#active?' do
  #   it 'returns true if the subscription is active' do
  #     subscription = create(:subscription, status: 'active')

  #     expect(subscription.user.active?).to be true
  #   end
  # end
end
