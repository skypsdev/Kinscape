require 'swagger_helper'

RSpec.describe Api::V1::Invitations::ResendsController, type: :request do
  let(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let(:recipient) { create :user }
  let!(:invitation) { create :invitation, family: family, sender: user, recipient: recipient, email: recipient.email }

  path '/api/v1/invitations/resend' do
    post('resend invitations') do
      include_context 'cookie'
      tags 'Invitation'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          ids: { type: :string }
        },
        required: [:ids]
      }
      let(:payload) do
        {
          ids: [invitation.id]
        }
      end

      before do
        stub_mandrill
      end

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(all_emails.map(&:to).flatten).to contain_exactly(recipient.email)
        end
      end
    end
  end
end
