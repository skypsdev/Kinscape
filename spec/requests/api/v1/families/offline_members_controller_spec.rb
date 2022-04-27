require 'swagger_helper'

RSpec.describe Api::V1::Families::OfflineMembersController, type: :request do
  let(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let(:kinship) { user.kinships.find_by(family: family) }
  let(:family_id) { family.id }
  let(:id) { kinship.id }

  path '/api/v1/families/{family_id}/offline_members' do
    parameter name: 'family_id', in: :path, type: :string

    post('create offline_member') do
      include_context 'cookie'
      tags 'Offline Member'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          avatar: { type: :string },
          nickname: { type: :string },
          description: { type: :string },
          profile_attrs: { type: :json }
        }
      }
      let(:image_blob) { create_file_blob }
      let(:payload) do
        {
          avatar: image_blob.signed_id,
          nickname: 'johnny bravo',
          description: 'my fav anime character',
          profile_attrs: {
            emails: [
              {
                value: 'johnny@email.com',
                name: 'email - private'
              }
            ]
          }
        }
      end

      before do
        stub_mandrill
      end

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['nickname']).to eq('johnny bravo')
          expect(response.parsed_body['data']['attributes']['role']).to eq('offline_member')
        end
      end
    end
  end

  path '/api/v1/families/{family_id}/offline_members/{id}' do
    parameter name: 'family_id', in: :path, type: :string
    parameter name: 'id', in: :path, type: :string

    patch('update offline_member') do
      include_context 'cookie'
      tags 'Offline Member'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          avatar: { type: :string },
          nickname: { type: :string },
          description: { type: :string },
          profile_attrs: { type: :json }
        }
      }
      let(:image_blob) { create_file_blob }
      let(:payload) do
        {
          avatar: image_blob.signed_id,
          nickname: 'johnny bravo',
          description: 'my fav anime character',
          profile_attrs: {
            emails: [
              {
                value: 'johnny@email.com',
                name: 'email - private'
              }
            ]
          }
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['nickname']).to eq('johnny bravo')
        end
      end
    end
  end
end
