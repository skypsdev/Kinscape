require 'swagger_helper'
RSpec.describe Api::V1::SignInController, type: :request do
  path '/api/v1/sign_in' do
    post('session create') do
      tags 'User - API'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          session: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            }
          }
        }
      }
      let(:payload) do
        {
          session: {
            email: email,
            password: password
          }
        }
      end
      let(:password) { 'secret' }
      let(:email) { 'secret@email.com' }

      before { create :user, email: email, password: password }

      response(302, 'successful', save_request_example: :payload) do
        run_test!
      end
    end
  end
end
