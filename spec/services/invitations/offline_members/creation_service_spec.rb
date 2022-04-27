require 'spec_helper'

describe Invitations::OfflineMembers::CreationService do
  subject(:result) do
    described_class.call(kinship: offline_member, params: params, current_user: user)
  end

  let(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let(:recipient) { create :user }
  let!(:offline_member) { create :offline_member, family: family }
  let(:kinship_id) { offline_member.id }
  let(:role) { 'co_admin' }
  let(:id) { nil }
  let(:email) { nil }
  let(:params) do
    {
      message: 'some',
      email: email,
      id: id,
      role: role
    }
  end

  before do
    stub_mandrill
  end

  context 'when user does not exist' do
    let(:email) { 'test@example.com' }

    it 'creates an invitation' do
      expect { result }.to change(Invitation, :count).by(1)
      expect(result.email).to eq email
      expect(result.kinship).to eq offline_member
      expect(result.family).to be_present
      expect(result.recipient).to be_nil
    end
  end

  context 'when user with that email exists' do
    let(:email) { recipient.email }

    it 'does not create an invitation' do
      expect { result }.to change(Invitation, :count).by(1)
      expect(result.email).to eq(email)
      expect(result.family).to eq(family)
      expect(result.recipient).to eq(recipient)
    end
  end

  context 'when user was invited and joined family, then left family and now is joining again :)' do
    let(:email) { recipient.email }
    let!(:invitation) do
      create :invitation, family: family, sender: user, accepted_at: Time.current, kinship: offline_member
    end

    it 'does not create an invitation' do
      expect { result }.to change(Invitation, :count).by(0)
      expect(invitation.reload.accepted_at).to be_nil
      expect(result.email).to eq email
      expect(result.family).to be_present
    end
  end

  context 'when invalid email' do
    let(:email) { 'bad_email' }

    it 'does not crate an invitation' do
      expect { result }.to avoid_changing(Invitation, :count)
    end
  end

  context 'when user already in the family' do
    before { create :kinship, family: family, user: recipient }

    it 'does nothing' do
      expect { result }.to avoid_changing(family.users, :count)
        .and avoid_changing(Invitation, :count)
    end
  end
end
