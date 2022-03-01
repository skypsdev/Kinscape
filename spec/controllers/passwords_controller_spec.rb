require 'spec_helper'

describe PasswordsController, type: :controller do
  describe '#create' do
    subject(:result) { post :create, params: params }

    let(:user) { create :user, confirmed_at: Time.current }
    let(:params) { { password: { email: user.email } } }

    it 'sends mail to user with newly created token' do
      stub_mandrill
      expect { result }.to change { user.reload.confirmation_token }
        .from(nil)
        .to(be_present)
      expect(result).to be_successful
      expect(result.parsed_body['errors']).to be_nil
      expect(emailed_addresses).to contain_exactly(user.email)
      expect(controller.flash['alert']).to eq('If the email is in the database, then you will receive an email soon.')
    end

    context 'with user not confirmed' do
      let(:user) { create :user, confirmed_at: nil }

      it 'does nothing' do
        expect { result }.to(avoid_changing { user.reload.confirmation_token })
        expect(result).to be_successful
        expect(result.parsed_body['errors']).to be_nil
        expect(emailed_addresses).to eq([])
        expect(controller.flash['alert']).to eq('If the email is in the database, then you will receive an email soon.')
      end
    end
  end
end
