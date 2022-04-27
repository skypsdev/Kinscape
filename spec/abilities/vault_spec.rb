require 'spec_helper'
require 'cancan/matchers'

describe 'Vault abilities' do
  subject(:ability) { Ability.new(current_user.reload) }

  let(:admin) { create(:user) }
  let(:user) { create(:user) }
  let!(:family) { create(:family, users: [admin, user]) }
  let(:vault) { family.vault }
  let(:current_user) { user }
  let(:subscription) do
    create :subscription,
           user: current_user,
           current_period_start: Time.current - 1.day,
           current_period_end: Time.current + 1.day
  end
  let(:family_subscription) do
    create :family_subscription,
           user: current_user,
           family: family,
           current_period_start: Time.current - 1.day,
           current_period_end: Time.current + 1.day
  end

  context 'when user is a family admin' do
    let(:current_user) { admin }

    # TODO-SUBSCRIPTION
    # it { is_expected.not_to be_able_to(:add_boxes_to_vault, vault) }
    # context 'with paid admin' do
    #   before { subscription }
    #   it { is_expected.not_to be_able_to(:add_boxes_to_vault, vault) }
    # end
    # TODO-SUBSCRIPTION END

    context 'with paid family' do
      # before { family_subscription }

      it { is_expected.to be_able_to(:add_boxes_to_vault, vault) }
    end
  end

  context 'when user is a family member' do
    # TODO-SUBSCRIPTION
    # it { is_expected.not_to be_able_to(:add_boxes_to_vault, vault) }

    context 'with paid member' do
      before { subscription }

      it { is_expected.to be_able_to(:add_boxes_to_vault, vault) }
    end
  end

  context 'when using own private vault' do
    let(:vault) { user.vault }

    # TODO-SUBSCRIPTION
    # it { is_expected.not_to be_able_to(:add_boxes_to_vault, vault) }

    context 'with paid member' do
      before { subscription }

      it { is_expected.to be_able_to(:add_boxes_to_vault, vault) }
    end
  end

  context 'when user is not a family member' do
    let(:current_user) { create :user }

    it { is_expected.not_to be_able_to(:add_boxes_to_vault, vault) }
  end

  context 'when the user is guest' do
    before do
      current_user.kinships.first.update!(role: :guest)
    end

    it { is_expected.not_to be_able_to(:add_boxes_to_vault, vault) }
  end
end
