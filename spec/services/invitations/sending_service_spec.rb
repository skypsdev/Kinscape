require 'spec_helper'

describe Invitations::SendingService do
  subject(:result) do
    described_class.call(family: family.reload, user_params: user_params, current_user: sender, message: message)
  end

  let(:user_params) { { email: email, role: 'co_admin' } }
  let(:message) { nil }
  let!(:sender) { create :user }
  let!(:family) { create :family, users: [sender] }
  let(:delivery) { instance_double(ActionMailer::MessageDelivery) }
  let(:email) { recipient.email }
  let!(:recipient) { create :user }

  context 'when user does not exist' do
    let(:email) { 'test@example.com' }

    it 'creates an invitation' do
      allow(Mailer).to receive(:invitation).and_return(delivery)
      allow(delivery).to receive(:deliver_now)

      expect { result }.to change(Invitation, :count).by(1)
      expect(result).to eq({ valid: email })
      invitation = Invitation.find_by(email: email)
      expect(invitation.family).to be_present
      expect(Mailer).to have_received(:invitation)
    end

    context 'when user was invited before' do
      let(:email) { recipient.email }
      let!(:invitation) do
        create :invitation, family: family, recipient: recipient, sender: sender, accepted_at: Time.current
      end

      it 'does not create an invitation' do
        allow(Mailer).to receive(:existing_user_invitation).and_return(delivery)
        allow(delivery).to receive(:deliver_now)

        expect { result }.to change(Invitation, :count).by(0)
        expect(invitation.reload.accepted_at).to be_nil
        expect(invitation.family).to be_present
        expect(result).to eq({ valid: email })
        expect(Mailer).to have_received(:existing_user_invitation)
      end
    end
  end

  context 'when user with that email exists' do
    it 'does not create an invitation' do
      allow(Mailer).to receive(:existing_user_invitation).and_return(delivery)
      allow(delivery).to receive(:deliver_now)

      expect { result }.to change(Invitation, :count).by(1)
      expect(result).to eq({ valid: email })
      invitation = Invitation.find_by(email: email)
      expect(invitation.family).to eq(family)
      expect(invitation.recipient).to eq(recipient)
      expect(Mailer).to have_received(:existing_user_invitation)
    end
  end

  context 'when invalid email' do
    let(:email) { 'bad_email' }

    it 'does not crate an invitation' do
      expect { result }.to avoid_changing(Invitation, :count)
        .and avoid_changing(ActionMailer::Base.deliveries, :size)
      expect(result).to eq({ invalid: email })
    end
  end

  context 'when user already in the family' do
    before { create :kinship, family: family, user: recipient }

    it 'does nothing' do
      expect { result }.to avoid_changing(family.users, :count)
        .and avoid_changing(ActionMailer::Base.deliveries, :size)
        .and avoid_changing(Invitation, :count)
      expect(result).to eq({ existing: email })
    end
  end
end
