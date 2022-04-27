require 'spec_helper'

describe Family, type: :model do
  context 'associations' do
    it { is_expected.to have_one(:vault) }
    it { is_expected.to have_one(:admin_kinship) }
    it { is_expected.to have_one(:admin) }
    it { is_expected.to have_many(:co_admin_kinships) }
    it { is_expected.to have_many(:co_admins) }
    it { is_expected.to have_many(:invitations) }
    it { is_expected.to have_many(:stories) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:subscriptions) }
    it { is_expected.to have_one(:active_subscription) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:family_type) }
    it { is_expected.to validate_presence_of(:kinships) }
  end

  context 'personal_not_changed' do
    let!(:family) { create(:family) }

    it do
      expect { family.update!(access_type: 'private') }
        .to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Access type - attribute change not allowed')
    end
  end

  describe '#kinship_for' do
    it 'returns the kinship for user' do
      user_1 = create(:user)
      user_2 = create(:user)
      family = create(:family, users: [user_1, user_2])
      result = family.kinship_for(user_2)

      expect(result).to eq user_2.kinships.first
    end
  end

  describe '#active?' do
    let(:user)   { create(:user) }
    let(:family) { create(:family, users: [user]) }

    context 'family admin subscription is active' do
      before do
        create(:subscription, user: user, status: 'active')
      end

      it 'returns true' do
        expect(family).to be_active
      end
    end

    context 'family admin subscription is not active' do
      it 'returns true' do # TODO: stripe suspend
        expect(family).to be_active
      end
    end
  end
end
