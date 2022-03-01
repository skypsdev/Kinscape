require 'spec_helper'
require 'cancan/matchers'

describe 'Vault box abilities' do
  subject(:ability) { Ability.new(current_user.reload) }

  let(:admin) { create(:user) }
  let(:family_member) { create(:user) }
  let!(:family) { create(:family, users: [admin, family_member]) }
  let(:box) { create :box, vault: vault }

  context 'with family vault' do
    let(:vault) { create :vault, owner: family }

    context 'when user is a family member' do
      let(:current_user) { admin }

      it do
        expect(ability).to be_able_to(:manage, box)
      end
    end

    context 'when user is a guest' do
      let(:guest) { create(:user) }
      let(:current_user) { guest }

      before do
        create :kinship, user: guest, family: family, role: :guest
      end

      it do
        expect(ability).to be_able_to(:read, box)
        expect(ability).not_to be_able_to(:manage, box)
      end
    end
  end

  context 'with private vault' do
    let(:vault) { admin.vault }

    context 'when user is a vault owner' do
      let(:current_user) { admin }

      it do
        expect(ability).to be_able_to(:manage, box)
      end
    end

    context 'when user is a family member' do
      let(:current_user) { family_member }

      it do
        expect(ability).not_to be_able_to(:read, box)
        expect(ability).not_to be_able_to(:manage, box)
      end
    end
  end
end
