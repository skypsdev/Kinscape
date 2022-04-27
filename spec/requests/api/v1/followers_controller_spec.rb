require 'swagger_helper'

RSpec.describe Api::V1::FollowersController, type: :request do
  let(:user) { create :user }
  let(:follower) { create :user }
  let!(:follower_kinship) { create :follower, family: user.personal_family, user: follower }

  path '/api/v1/followers' do
    get('list followers') do
      include_context 'cookie'
      tags 'Follower'

      parameter name: :query, in: :query, type: :string
      parameter name: :showcase, in: :query, type: :boolean

      let(:showcase) { nil }
      let(:query) { follower_kinship.nickname }

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].first['id']).to eq(follower_kinship.id.to_s)
        end
      end
    end
  end
end
