require 'swagger_helper'

RSpec.describe Api::V1::Kinships::InvitationsController, type: :request do
  let(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let(:recipient) { create :user }
  let!(:offline_member) { create :offline_member, family: family }
  let(:kinship_id) { offline_member.id }

  path '/api/v1/kinships/{kinship_id}/invitation' do
    parameter name: 'kinship_id', in: :path, type: :string

    post('offline member to active: create invitation - user_id or email required') do
      include_context 'cookie'
      tags 'Offline Member'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          message: { type: :string },
          email: { type: :string },
          role: { type: :string, enum: Kinship.roles.keys.excluding('admin') },
          user_id: { type: :string }
        }
      }
      let(:email) { 'non_db@valid.com' }
      let(:role) { 'co_admin' }
      let(:payload) do
        {
          invitation: {
            message: 'some',
            email: email,
            user_id: nil,
            role: role
          }
        }
      end

      before do
        stub_mandrill
      end

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['email']).to eq(email)
        end
      end
    end
  end
end
