require 'swagger_helper'

RSpec.describe Api::V1::Families::InvitationsController, type: :request do
  let(:user) { create :user }
  let(:existing) { create :user }
  let!(:family) { create :family, users: [user, existing] }
  let(:recipient) { create :user }
  let!(:invitation) { create :invitation, family: family, sender: user, recipient: recipient, email: recipient.email }
  let(:family_id) { family.uid }
  let(:id) { invitation.id }

  before do
    stub_mandrill
  end

  path '/api/v1/families/{family_id}/invitations' do
    parameter name: 'family_id', in: :path, type: :string

    get('list invitations') do
      include_context 'cookie'
      tags 'Invitation'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].count).to eq(1)
          expect(response.parsed_body['data'].first['id']).to eq(invitation.id.to_s)
        end
      end
    end

    post('create invitation') do
      include_context 'cookie'
      tags 'Invitation'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          message: { type: :string },
          users: {
            type: :array,
            items: {
              type: :object,
              properties: {
                email: { type: :string },
                id: { type: :string },
                role: { type: :string, enum: Kinship.roles.keys.excluding('admin') }
              }
            }
          }
        }
      }
      let(:role) { 'co_admin' }
      let(:payload) do
        {
          invitation: {
            message: 'some',
            users: [
              {
                email: 'some_email@valid.com',
                id: nil,
                role: role
              },
              {
                email: 'invalid.com',
                id: nil,
                role: role
              },
              {
                email: existing.email,
                id: nil,
                role: role
              }
            ]
          }
        }
      end

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['errors']).to be_nil
          expect(response.parsed_body['valid']).to eq(['some_email@valid.com'])
          expect(response.parsed_body['invalid']).to eq(['invalid.com'])
          expect(response.parsed_body['existing']).to eq([existing.email])
          expect(emailed_addresses).to contain_exactly('some_email@valid.com')
          expect(family.invitations.last.role).to eq('co_admin')
        end
      end
    end
  end
end
