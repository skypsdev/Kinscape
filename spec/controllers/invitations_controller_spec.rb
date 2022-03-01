require 'spec_helper'

describe InvitationsController, type: :controller do
  let(:sender) { create :user }
  let(:family) { create :family, users: [sender] }
  let!(:invitation) { create :invitation, family: family, sender: sender, email: 'first@last.com' }

  describe '#decline' do
    subject(:result) { get :decline, params: { id: invitation.id } }

    it 'decline invitation' do
      expect { result }.to change(Invitation, :count)
        .from(1)
        .to(0)
    end
  end
end
