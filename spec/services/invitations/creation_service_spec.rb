require 'spec_helper'

describe Invitations::CreationService do
  subject(:result) do
    described_class.call(family: family.reload, user_params: user_params, current_user: sender, message: message)
  end

  let(:user_params) { { email: email, role: 'co_admin' } }
  let(:message) { nil }
  let!(:sender) { create :user }
  let!(:family) { create :family, users: [sender] }
  let(:email) { recipient.email }
  let!(:recipient) { create :user }

  before do
    stub_mandrill
  end

  context 'when user does not exist' do
    let(:email) { 'test@example.com' }

    it 'creates an invitation' do
      expect { result }.to change(Invitation, :count).by(1)
      expect(result).to eq({ valid: email })
      invitation = Invitation.find_by(email: email)
      expect(invitation.family).to be_present
      expect(all_emails.map(&:subject)).to contain_exactly(
        "#{family.kinship_for(sender).nickname} invited you to join Kinscape"
      )
    end

    context 'with personal family' do
      let(:family) { sender.personal_family }

      it 'creates an invitation with role guest' do
        expect { result }.to change(Invitation, :count).by(1)
        expect(result).to eq({ valid: email })
        invitation = Invitation.find_by(email: email)
        expect(invitation.family).to be_present
        expect(invitation.role).to eq('guest')
        expect(all_emails.map(&:subject)).to contain_exactly(
          "#{family.kinship_for(sender).nickname} invited you to join Kinscape"
        )
      end
    end

    context 'when user was invited before' do
      let(:email) { recipient.email }
      let!(:invitation) do
        create :invitation, family: family, recipient: recipient, sender: sender, accepted_at: Time.current
      end

      it 'does not create an invitation' do
        expect { result }.to change(Invitation, :count).by(0)
        expect(invitation.reload.accepted_at).to be_nil
        expect(invitation.family).to be_present
        expect(result).to eq({ valid: email })
        expect(all_emails.map(&:subject)).to contain_exactly('Community Invitation')
      end
    end
  end

  context 'when user with that email exists' do
    it 'does not create an invitation' do
      expect { result }.to change(Invitation, :count).by(1)
      expect(result).to eq({ valid: email })
      invitation = Invitation.find_by(email: email)
      expect(invitation.family).to eq(family)
      expect(invitation.recipient).to eq(recipient)
      expect(all_emails.map(&:subject)).to contain_exactly('Community Invitation')
    end
  end

  context 'when invalid email' do
    let(:email) { 'bad_email' }

    it 'does not crate an invitation' do
      expect { result }.to avoid_changing(Invitation, :count)
        .and avoid_changing(ActionMailer::Base.deliveries, :size)
      expect(result).to eq({ invalid: email })
      expect(all_emails.size).to eq(0)
    end
  end

  context 'when user already in the family' do
    before { create :kinship, family: family, user: recipient }

    it 'does nothing' do
      expect { result }.to avoid_changing(family.users, :count)
        .and avoid_changing(ActionMailer::Base.deliveries, :size)
        .and avoid_changing(Invitation, :count)
      expect(result).to eq({ existing: email })
      expect(all_emails.size).to eq(0)
    end
  end
end
