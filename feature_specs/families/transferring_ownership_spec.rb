require 'spec_helper'

feature 'Transferring Family ownership', :js do
  let(:transferor) { create :user, subscription: transferor_subscription }
  let(:transferee) { create :user, subscription: transferee_subscription }
  let(:transferor_subscription) { build :subscription, status: 'active' }
  let(:transferee_subscription) { build :subscription, status: 'active' }

  let(:family) do
    create :family, connector: transferor, users: [transferor, transferee]
  end

  let(:invitation_token) do
    JwtService.encode(
      transferor_id: transferor.id,
      transferee_id: transferee.id,
      family_ids: [family.id]
    )
  end

  let(:fraud_token) do
    %w(
      eyJhbGciOiJIUzI1NiJ9
      eyJ0cmFuc2Zlcm9yX2lkIjoxLCJ0cmFuc2ZlcmVlX2lkIjoyLCJmYW1pbHlfaWRzIjpbMV19
      UjK_UrbqAlhieOX_vPuyHQslPsnwuqgLV44EYluZBfY
    ).join('.')
  end

  let(:invitation_path) { families_ownership_transfer_path(invitation_token) }

  scenario 'a transferee reviews invitation' do
    visit invitation_path

    expect(page).to have_text 'Become Connector'
    expect(page).to have_text 'would like you to become Family Connector'
    expect(page).to have_text family.name
  end

  scenario 'a transferee accepts invitation' do
    allow(Billing::SubscriptionService).to receive(:subscribe)

    visit invitation_path
    click_on 'Accept'

    expect(page).to have_current_path(families_path)
    expect(page).to have_text family.name
  end

  context 'when token is fraud' do
    let(:invitation_token) { fraud_token }

    scenario 'user gets redirected to ownership preview page' do
      visit invitation_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_text 'went wrong'
    end
  end
end
