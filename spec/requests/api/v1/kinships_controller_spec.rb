require 'swagger_helper'

RSpec.describe Api::V1::KinshipsController, type: :request do
  let(:user) { create :user }
  let(:other_user) { create :user }
  let!(:family) { create :family, users: [user, other_user] }
  let(:user_kinship) { user.kinships.find_by(family: family) }
  let(:other_kinship) { other_user.kinships.find_by(family: family) }
  let(:id) { other_kinship.id }

  path '/api/v1/kinships/by_family/{family_id}' do
    parameter name: 'family_id', in: :path, type: :string
    let(:family_id) { family.uid }

    get('show kinship') do
      include_context 'cookie'
      tags 'Kinship'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(user_kinship.id.to_s)
        end
      end
    end
  end

  path '/api/v1/kinships/kinship_data' do
    parameter name: :family_id, in: :query, type: :string
    parameter name: :user_id, in: :query, type: :string
    let(:family_id) { family.uid }
    let(:user_id) { user.id }

    get('kinship_data kinship') do
      include_context 'cookie'
      tags 'Kinship'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(user_kinship.id.to_s)
        end
      end
    end
  end

  path '/api/v1/kinships/{id}/upload_config' do
    parameter name: 'id', in: :path, type: :string

    get('upload_config kinship') do
      deprecated true
      include_context 'cookie'
      tags 'Kinship'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body).to eq({})
        end
      end
    end
  end

  path '/api/v1/kinships/{id}' do
    parameter name: 'id', in: :path, type: :string

    get('show kinship') do
      include_context 'cookie'
      tags 'Kinship'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(other_kinship.id.to_s)
        end
      end
    end

    patch('update kinship') do
      include_context 'cookie'
      tags 'Kinship'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          avatar: { type: :string },
          nickname: { type: :string },
          location: { type: :string },
          birth_date: { type: :string },
          birth_place: { type: :string },
          death_date: { type: :string },
          address: { type: :string },
          phone: { type: :string },
          email: { type: :string },
          profile_attrs: { type: :json },
          rich_profile: {
            type: :object,
            properties: {
              body: { type: :string }
            }
          }
        }
      }
      let(:payload) do
        {
          avatar: image_blob.signed_id,
          nickname: 'some nickname',
          location: 'some location',
          birth_date: '2020',
          birth_place: 'January',
          death_date: '2',
          address: '1',
          phone: '2020',
          email: 'February',
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
          },
          rich_profile: {
            body: 'some body'
          }
        }
      end
      let(:image_blob) { create_file_blob }
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['nickname']).to eq('some nickname')
        end
      end
    end

    delete('destroy kinship') do
      include_context 'cookie'
      tags 'Kinship'

      response(204, 'successful') do
        before do
          expect(Kinship.count).to eq(2)
        end

        run_test! do
          expect(Kinship.count).to eq(1)
        end
      end

      response(401, 'admin delete', document: false) do
        let(:id) { user_kinship.id }
        run_test!
      end
    end
  end
end
