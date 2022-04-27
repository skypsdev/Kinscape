require 'swagger_helper'

RSpec.describe Api::V1::FollowingsController, type: :request do
  let(:user) { create :user }
  let(:following) { create :user }
  let(:id) { following.personal_kinship.id }

  before do
    create :follower, family: following.personal_family, user: user
  end

  path '/api/v1/followings' do
    get('list followings') do
      include_context 'cookie'
      tags 'Following'

      parameter name: :query, in: :query, type: :string
      parameter name: :showcase, in: :query, type: :boolean

      let(:showcase) { nil }
      let(:query) { following.personal_kinship.nickname }

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].first['id']).to eq(id.to_s)
        end
      end
    end
  end

  path '/api/v1/followings/{id}' do
    parameter name: 'id', in: :path, type: :string

    get('show following') do
      include_context 'cookie'
      tags 'Following'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(id.to_s)
        end
      end
    end

    delete('unfollow') do
      include_context 'cookie'
      tags 'Following'

      response(204, 'successful') do
        before do
          expect(Kinship.count).to eq(5)
        end

        run_test! do
          expect(Kinship.count).to eq(4)
        end
      end
    end
  end
end
