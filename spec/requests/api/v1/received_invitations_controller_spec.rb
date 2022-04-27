require 'swagger_helper'

RSpec.describe Api::V1::ReceivedInvitationsController, type: :request do
  let(:user) { create :user }
  let(:admin) { create :user }
  let(:family) { create :family, users: [admin] }
  let!(:invitation) { create :invitation, sender: admin, family: family, recipient: user }

  path '/api/v1/received_invitations' do
    get('list received_invitations') do
      include_context 'cookie'
      tags 'Received invitation'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].first['id']).to eq(invitation.id)
        end
      end
    end
  end
end
