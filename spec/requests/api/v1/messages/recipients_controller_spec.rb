require 'swagger_helper'

RSpec.describe Api::V1::Messages::RecipientsController, type: :request do
  let!(:user) { create :user }
  let!(:user_1) { create :user }
  let!(:user_2) { create :user }
  let!(:following) { create :user }
  let!(:follower) { create :user }
  let!(:follower_kinship) { create :follower, family: user.personal_family, user: follower }
  let!(:following_kinship) { create :follower, family: following.personal_family, user: user }
  let!(:family) { create(:family, users: [user], name: 'Z-last') }
  let!(:family_1) { create :family, name: 'Purrkins', users: [user, user_1] }
  let!(:family_2) { create :family, name: 'Barkins', users: [user, user_2] }
  let(:id) { family.id }

  before do
    follower_kinship.family.update(name: 'AA')
    following_kinship.family.update(name: 'CC')
  end

  path '/api/v1/messages/recipients' do
    get('list recipients') do
      include_context 'cookie'
      tags 'Messages'
      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].size).to eq 5
          expect(response.parsed_body['data'][0]['attributes']['name']).to eq follower_kinship.family.name
          expect(response.parsed_body['data'][1]['attributes']['name']).to eq family_2.name
          expect(response.parsed_body['data'][2]['attributes']['name']).to eq following_kinship.family.name
          expect(response.parsed_body['data'][3]['attributes']['name']).to eq family_1.name
          expect(response.parsed_body['data'][4]['attributes']['name']).to eq 'Z-last'
          user_ids = response.parsed_body['included'].map { |x| x['attributes']['user_id'] }.uniq
          expect(user_ids).to contain_exactly(following.id, follower.id, user_1.id, user_2.id)
          expect(user_ids).not_to include(user.id)
        end
      end
    end
  end
end
