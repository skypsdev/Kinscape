require 'swagger_helper'

RSpec.describe Api::V1::Publications::AppreciationsController, type: :request do
  let(:user) { create :user }
  let(:story_author) { create :user }
  let(:family) { create :family, users: [user] }
  let(:story) { create :story, families: [family], user: story_author }
  let!(:publication) { create :publication, family: family, story: story }
  let(:publication_id) { publication.id }

  before do
    # extra user
    create :user
  end

  path '/api/v1/publications/{publication_id}/appreciations' do
    parameter name: 'publication_id', in: :path, type: :string

    post('create appreciation') do
      include_context 'cookie'
      tags 'Appreciation'

      parameter name: :appreciation, in: :body, schema: {
        type: :object,
        properties: {
          reaction: { type: :string, enum: ['smile'] },
          appreciable_id: { type: :string },
          appreciable_type: { type: :string, enum: ['Story'] }
        },
        required: %w[reaction appreciable_id appreciable_type]
      }
      let(:appreciation) do
        {
          reaction: 'smile',
          appreciable_id: story.uid,
          appreciable_type: 'Story'
        }
      end
      response(200, 'successful') do
        before do
          stub_mandrill
        end

        run_test! do
          expect(response.parsed_body['data']['attributes']['appreciable_id']).to eq publication_id
        end
      end
    end
  end

  path '/api/v1/publications/{publication_id}/appreciations/{id}' do
    parameter name: 'publication_id', in: :path, type: :string
    parameter name: 'id', in: :path, type: :string

    delete('delete appreciation') do
      include_context 'cookie'
      tags 'Appreciation'

      let!(:appreciation) { create :appreciation, user: user, appreciable: publication }
      let(:id) { appreciation.id }

      response(204, 'successful') do
        before do
          expect(Appreciation.count).to eq 1
        end

        run_test! do
          expect(Appreciation.count).to eq 0
        end
      end
    end
  end
end
