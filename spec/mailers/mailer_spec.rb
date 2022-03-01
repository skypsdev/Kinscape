require 'spec_helper'

RSpec.describe Mailer, type: :mailer do
  describe 'email_confirmation' do
    subject(:mail) { described_class.email_confirmation(recipient: user, invitation_id: nil) }

    let(:user) { create(:user, first_name: 'John', confirmation_token: 'some') }

    it do
      VCR.use_cassette('mailer/email_confirmation') do
        expect(mail.subject).to eq('Email confirmation instructions')
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(['welcome@kinscape.com'])
        expect(mail.body.encoded).not_to include('RECIPIENT_NAME')
        expect(mail.body.encoded).to include("Welcome #{user.first_name}")
        expect(mail.body.encoded).to include(user.confirmation_token)
      end
    end
  end

  describe 'reset_password' do
    subject(:mail) { described_class.reset_password(recipient: user) }

    let(:user) { create(:user, first_name: 'John', last_name: 'Rambo', confirmation_token: 'some') }

    it do
      VCR.use_cassette('mailer/reset_password') do
        expect(mail.subject).to eq('Forgot your password?')
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(['welcome@kinscape.com'])
        expect(mail.body.encoded).not_to include('RECIPIENT_NAME')
        expect(mail.body.encoded).to include("Hello #{user.name}")
        expect(mail.body.encoded).to include(user.confirmation_token)
      end
    end

    context 'with fake mail' do
      let(:user) do
        create(:user,
               email: 'asd@fake.kinscape.com',
               first_name: 'John',
               last_name: 'Rambo',
               confirmation_token: 'some')
      end

      it "doesn't send mail" do
        VCR.use_cassette('mailer/reset_password_fake') do
          expect(mail.subject).to be_nil
          expect(mail.to).to be_nil
          expect(mail.from).to be_nil
          expect(mail.body).to be_empty
        end
      end
    end
  end

  describe 'invitation' do
    subject(:mail) { described_class.invitation(invitation: invitation) }

    let(:user) { create(:user, first_name: 'John', last_name: 'Rambo') }
    let(:family) { create :family, name: 'my family', users: [user] }
    let(:new_user_email) { 'test@email.com' }
    let(:invitation) do
      create(:invitation, family: family, sender: user, email: new_user_email, message: 'test message')
    end

    it do
      VCR.use_cassette('mailer/invitation') do
        expect(mail.subject).to eq("#{user.name} has invited you to join a community")
        expect(mail.to).to eq([new_user_email])
        expect(mail.from).to eq(['welcome@kinscape.com'])
        expect(mail.body.encoded).not_to include('SENDER_NAME')
        expect(mail.body.encoded).to include("#{user.name} has invited you")
        expect(mail.body.encoded).to include(family.name)
        expect(mail.body.encoded).to include(invitation.message)
      end
    end
  end

  describe 'existing_user_invitation' do
    subject(:mail) { described_class.existing_user_invitation(invitation: invitation) }

    let(:user) { create(:user, first_name: 'John', last_name: 'Rambo') }
    let(:family) { create :family, name: 'my family', users: [user] }
    let(:recipient) { create(:user, first_name: 'Baby', last_name: 'Yoda', email: 'baby@yoda.com') }
    let(:invitation) do
      create(:invitation,
             family: family,
             sender: user,
             email: recipient.email,
             recipient: recipient,
             message: 'test message')
    end

    it do
      VCR.use_cassette('mailer/existing_user_invitation') do
        expect(mail.subject).to eq("#{user.name} has invited you to join a community")
        expect(mail.to).to eq([recipient.email])
        expect(mail.from).to eq(['welcome@kinscape.com'])
        expect(mail.body.encoded).not_to include('SENDER_NAME')
        expect(mail.body.encoded).to include("#{user.name} has invited you")
        expect(mail.body.encoded).to include(invitation.message)
        expect(mail.body.encoded).to include(family.name)
      end
    end
  end

  describe 'active_member_to_offline' do
    subject(:mail) { described_class.active_member_to_offline(family: family, user: user) }

    let(:admin) { create :user, first_name: 'John', last_name: 'Rambo' }
    let(:user) { create :user, email: 'const@email.com' }
    let(:family) { create :family, name: 'my family', users: [admin, user] }

    it do
      VCR.use_cassette('mailer/active_member_to_offline') do
        expect(mail.subject).to eq('TODO-OFFLINE-MEMBER')
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(['welcome@kinscape.com'])
        expect(mail.body.encoded).not_to include('ADMIN_NAME')
        expect(mail.body.encoded).to include("#{admin.name} has removed you from")
      end
    end
  end

  describe 'send_message' do
    subject(:mail) { described_class.send_message(**params) }

    let(:params) do
      {
        sender: sender,
        message: message,
        family: family,
        recipients: recipients,
        recipients_name: recipients_name
      }
    end
    let(:family) { create :family, name: 'my family', users: [sender] }
    let(:sender) { create(:user, first_name: 'John', last_name: 'Rambo') }
    let(:kinship) { sender.kinships.find_by(family: family) }
    let(:message) { 'some message' }
    let(:recipient1) { create(:user, first_name: 'Baby', last_name: 'Yoda', email: 'baby@yoda.com') }
    let(:recipient2) { create(:user, first_name: 'fake', last_name: 'fake', email: 'fake@fake.kinscape.com') }
    let(:recipients) { [recipient1, recipient2].map { |member| "#{member.name} <#{member.email}>" } }
    let(:recipients_name) { [recipient1, recipient2].pluck(:name) }

    it 'sends message without fake mails' do
      VCR.use_cassette('mailer/send_message') do
        expect(mail.subject).to eq("#{sender.name} has sent you a message")
        expect(mail.to).to eq([recipient1.email])
        expect(mail.from).to eq(['welcome@kinscape.com'])
        expect(mail.body.encoded).not_to include('REQUESTER_NAME')
        expect(mail.body.encoded).to include(message)
        expect(mail.body.encoded).to include(family.name)
      end
    end
  end
end
