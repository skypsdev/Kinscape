require 'swagger_helper'

RSpec.describe Api::V1::Publications::FamiliesController, type: :request do
  let(:user) { create :user }
  let!(:family) { create :family, users: [user], name: 'A' }
  let!(:family_with_publication) { create :family, users: [user] }
  let(:story) { create :story, user: user }
  let(:publication_id) { story.private_publication.id }
  let!(:guested_family) do
    create(:family, users: [user]).tap { |family| family.kinships.find_by(user: user).update(role: :guest) }
  end

  before do
    create(:publication, story: story, family: family_with_publication)
    user.personal_family.update!(name: 'Z - should be first in response')
  end

  path '/api/v1/publications/{publication_id}/families' do
    parameter name: :publication_id, in: :path, type: :string

    get('list available families for publications') do
      include_context 'cookie'
      tags 'Story'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].pluck('id')).to eq([user.personal_family.id, family.id])
          expect(response.parsed_body['data'].pluck('id')).not_to include(family_with_publication.id,
                                                                          guested_family.id)
        end
      end
    end
  end
end
