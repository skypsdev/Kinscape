require 'swagger_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:user) { create :user, password: 'current_password' }

  before { create :family, users: [user] }

  path '/api/v1/user' do
    patch('update user') do
      include_context 'cookie'
      tags 'User - API'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          email: { type: :string },
          current_password: { type: :string, description: 'required during email or password updating' },
          password: { type: :string },
          password_confirmation: { type: :string },
          onboarding: { type: :json }
        }
      }
      let(:payload) do
        {
          first_name: first_name,
          last_name: 'new last',
          email: email,
          current_password: current_password,
          password: password,
          password_confirmation: password_confirmation,
          onboarding: { completed: false }
        }
      end
      let(:current_password) { 'current_password' }
      let(:first_name) { 'new first' }
      let(:email) { 'some@new.email' }
      let(:password) { 'new_secret' }
      let(:password_confirmation) { 'new_secret' }

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['name']).to eq('new first new last')
          expect(response.parsed_body['data']['attributes']['email']).to eq('some@new.email')
          expect(response.parsed_body['data']['attributes']['onboarding']).to eq({ 'completed' => false })
          expect(User.authenticate('some@new.email', 'new_secret')).to eq(user)
        end
      end

      response(422, 'wrong email', document: false) do
        let(:email) { 'nneeeh' }
        run_test! do
          expect(response.parsed_body['errors']['detail']).to eq(['Email is invalid'])
        end
      end

      response(422, 'pass mismatch', document: false) do
        let(:password_confirmation) { 'nneeeh' }
        run_test! do
          expect(response.parsed_body['errors']['detail']).to eq(["Password confirmation doesn't match Password"])
        end
      end

      response(422, 'first name blank', document: false) do
        let(:first_name) { '' }
        run_test! do
          expect(response.parsed_body['errors']['detail']).to eq(["First Name can't be blank"])
        end
      end

      response(403, 'wrong current_password', document: false) do
        let(:current_password) { 'nneeeh' }
        run_test! do
          expect(response.parsed_body['message']).to eq('forbidden')
        end
      end
    end
  end
end
