require 'spec_helper'
require 'cancan/matchers'

describe 'Manage family ability' do
  subject(:ability) { Ability.new(user.reload) }

  let(:admin) { create(:user) }
  let(:family_member) { create(:user) }
  let!(:family) { create(:family, name: 'Some family', users: [admin, family_member]) }

  context 'when user is a family admin' do
    let(:user) { admin }

    it { is_expected.to be_able_to(:manage, family) }
  end

  context 'when user is not a family admin' do
    let(:user) { family_member }

    it { is_expected.not_to be_able_to(:manage, family) }
  end
end
