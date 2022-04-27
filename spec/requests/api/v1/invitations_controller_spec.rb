require 'swagger_helper'

RSpec.describe Api::V1::InvitationsController, type: :request do
  let(:admin) { create :user }
  let(:family) { create :family, users: [admin] }
  let(:user) { create :user }
  let!(:invitation) { create :invitation, sender: admin, family: family, recipient: user }
  let(:id) { invitation.id }

  path '/api/v1/invitations/{id}' do
    parameter name: 'id', in: :path, type: :string

    get('show invitation') do
      include_context 'cookie'
      tags 'Invitation'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(id)
        end
      end

      response(403, 'user already present in family') do
        before { create :kinship, user: user, family: family }

        run_test! do
          expect(response.parsed_body['message']).to eq('You are already in this community')
        end
      end
    end

    patch('update invitation') do
      include_context 'cookie'
      tags 'Invitation'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          nickname: { type: :string },
          profile_attrs: { type: :json }
        }
      }
      let(:image_blob) { create_file_blob }
      let(:payload) do
        {
          invitation: {
            avatar: image_blob.signed_id,
            nickname: 'some nickname',
            profile_attrs: {
              emails: [
                {
                  value: 'some@email.com',
                  name: 'email - private'
                },
                {
                  value: 'some_work@email.com',
                  name: 'email - work'
                }
              ]
            }
          }
        }
      end

      before do
        stub_mandrill
      end

      response(200, 'successful', save_request_example: :payload) do
        before do
          expect(Kinship.default_access.count).to eq(1)
        end

        run_test! do
          expect(Kinship.default_access.count).to eq(2)
          kinship = family.kinship_for(user)
          expect(kinship.nickname).to eq('some nickname')
          expect(kinship.avatar.attached?).to eq(true)
        end
      end

      context 'without email of existing user, without recipient in invitation' do
        let(:another) { create :user }
        let(:invitation) { create :invitation, sender: admin, family: family, recipient: nil, email: another.email }

        response(401, 'unauthorized') do
          run_test! do
            expect(response.parsed_body['message']).to eq('unauthorized')
          end
        end
      end
    end

    path '/api/v1/invitations' do
      delete('delete invitation') do
        include_context 'cookie'
        tags 'Invitation'

        parameter name: :payload, in: :body, schema: {
          type: :object,
          properties: {
            ids: { type: :array }
          }
        }
        let(:payload) { { ids: [invitation.id] } }

        response(204, 'successful', save_request_example: :payload) do
          before do
            stub_mandrill
            expect(Invitation.count).to eq(1)
          end

          run_test! do
            expect(Invitation.count).to eq(0)
          end
        end
      end
    end
  end
end
