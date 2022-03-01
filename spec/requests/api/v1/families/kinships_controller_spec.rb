require 'swagger_helper'

RSpec.describe Api::V1::Families::KinshipsController, type: :request do
  let!(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let(:kinship) { user.kinships.find_by(family: family) }

  path '/api/v1/families/{family_id}/kinships' do
    parameter name: 'family_id', in: :path, type: :string
    let(:family_id) { family.uid }

    get('list kinships') do
      include_context 'cookie'
      tags 'Kinship'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].first['id']).to eq(kinship.id.to_s)
        end
      end
    end
  end
end
