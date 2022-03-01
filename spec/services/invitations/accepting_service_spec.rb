require 'spec_helper'

describe Invitations::AcceptingService do
  subject(:result) { described_class.call(invitation, params, current_user) }

  let(:admin) { create :user, email: 'admin@email.com' }
  let(:current_user) { create :user, email: 'current_user@email.com' }
  let(:some_user) { create :user, email: 'family@user.com' }
  let(:family) { create :family, users: [admin, some_user] }
  let(:image_blob) { create_file_blob }
  let(:params) { { nickname: 'fl', avatar: create_file_blob.signed_id, profile_attrs: { some: 'thing' } } }
  let!(:invitation) do
    create :invitation,
           family: family,
           sender: admin,
           recipient: recipient,
           email: email, kinship: kinship,
           role: 'co_admin'
  end
  let(:kinship) { nil }

  before do
    stub_mandrill
  end

  context 'with recipient present' do
    let(:recipient) { current_user }
    let(:email) { current_user.email }

    it 'updates the accepted attribute and saves the recipient' do
      expect(result.accepted_at).to be_present
      new_kinship = recipient.kinships.find_by(family: family)
      expect(new_kinship.avatar.attached?).to eq(true)
      expect(new_kinship).to have_attributes(
        role: 'co_admin',
        inviter_id: admin.id,
        nickname: 'fl',
        profile_attrs: { 'some' => 'thing' }
      )
      expect(result.recipient.families).to include invitation.family
      expect(all_emails.map(&:to).flatten).to contain_exactly(admin.email, current_user.email, some_user.email)
    end
  end

  context 'with email of existing user, without recipient in invitation' do
    let(:recipient) { nil }
    let(:email) { current_user.email }

    it 'updates the accepted attribute and saves the recipient' do
      expect(result.accepted_at).to be_present
      expect(result.recipient).to eq current_user
      expect(result.recipient.families).to include invitation.family
      expect(all_emails.map(&:to).flatten).to contain_exactly(admin.email, current_user.email, some_user.email)
    end
  end

  context 'without email of existing user, without recipient in invitation' do
    let(:recipient) { nil }
    let(:email) { 'nondb@email.com' }

    it 'updates the accepted attribute and saves the recipient' do
      expect(result.accepted_at).to be_present
      expect(result.recipient).to eq current_user
      expect(result.recipient.families).to include invitation.family
      expect(all_emails.map(&:to).flatten).to contain_exactly(admin.email, current_user.email, some_user.email)
    end
  end

  context 'trying to accept someones else invitation' do
    let(:recipient) { nil }
    let(:another_user) { create :user }
    let(:email) { another_user.email }

    it 'updates the accepted attribute and saves the recipient' do
      expect { result }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'with offline member to active' do
    let!(:kinship) { create :offline_member, family: family }
    let(:recipient) { nil }
    let(:email) { 'nondb@email.com' }

    it 'updates the accepted attribute and saves the recipient' do
      expect { result }.to change { kinship.reload.user_id }.from(nil).to(current_user.id)
      expect(result.accepted_at).to be_present
      expect(result.recipient).to eq current_user
      expect(result.recipient.families).to include invitation.family
      expect(all_emails.map(&:to).flatten).to contain_exactly(admin.email, current_user.email, some_user.email)
    end
  end
end
