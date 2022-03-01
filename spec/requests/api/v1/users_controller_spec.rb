require 'swagger_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:user) { create :user }

  before { create :family, users: [user] }

  path '/api/v1/user' do
    patch('update user') do
      include_context 'cookie'
      tags 'User'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string }
        }
      }
      let(:payload) do
        {
          first_name: 'new first',
          last_name: 'new last'
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['name']).to eq('new first new last')
        end
      end
    end
  end
end
