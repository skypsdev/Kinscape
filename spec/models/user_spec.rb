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
    it { is_expected.to have_many(:owned_families) }
    it { is_expected.to have_many(:family_vaults) }
    it { is_expected.to have_many(:sections) }
    it { is_expected.to have_many(:publications) }
    it { is_expected.to have_many(:stories) }
    it { is_expected.to have_many(:subscriptions) }
    it { is_expected.to have_many(:family_subscriptions) }
    it { is_expected.to have_many(:followers) }
    it { is_expected.to have_many(:all_kinships) }
    it { is_expected.to have_many(:kinships) }
    it { is_expected.to have_many(:following_kinships) }
    it { is_expected.to have_many(:following_families) }
    it { is_expected.to have_many(:followers_families) }
    it { is_expected.to have_many(:followings) }
    it { is_expected.to have_one(:active_subscription) }
    it { is_expected.to have_one(:active_family_subscription) }
    it { is_expected.to have_one(:personal_kinship) }
    it { is_expected.to have_one(:personal_family) }
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
      expect(user.personal_kinship).to be_present
      expect(user.personal_family).to be_present
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
    let(:user) { create :user }
    let(:another_user) { create :user }
    let!(:family_1) { create :family, users: [another_user, user] }
    let!(:family_2) { create :family, users: [another_user, user] }

    before do
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
        .by(-4)
        .and change(Family, :count)
        .by(-1) # personal family
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
