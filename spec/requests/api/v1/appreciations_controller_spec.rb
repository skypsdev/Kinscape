require 'swagger_helper'

RSpec.describe Api::V1::AppreciationsController, type: :request do
  let(:user) { create :user }
  let(:story_author) { create :user }
  let(:family) { create :family, users: [user, story_author] }
  let(:chapter) { create :chapter_family, chapterable: family, author: user }
  let(:story) { create :story, user: story_author }
  let!(:publication) { create :publication, family: family, story: story }
  let(:publication_id) { publication.id }

  before do
    create :user
  end

  path '/api/v1/appreciations' do
    post('create appreciation') do
      include_context 'cookie'
      tags 'Appreciation'

      parameter name: :appreciation, in: :body, schema: {
        type: :object,
        properties: {
          reaction: { type: :string, enum: ['smile'] },
          appreciable_id: { type: :string },
          appreciable_type: { type: :string, enum: %w[Publication Section Chapter] },
          publication_id: { type: :string }
        },
        required: %w[reaction appreciable_id appreciable_type]
      }
      let(:appreciation) do
        {
          reaction: 'smile',
          appreciable_id: publication_id,
          appreciable_type: 'Publication',
          publication_id: publication_id
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

      response(200, 'successful', document: false) do
        let(:appreciation) do
          {
            reaction: 'smile',
            appreciable_id: chapter.id,
            appreciable_type: 'Chapter'
          }
        end
        before do
          stub_mandrill
        end

        run_test! do
          expect(response.parsed_body['data']['attributes']['appreciable_id']).to eq chapter.id
        end
      end
    end
  end

  path '/api/v1/appreciations/{id}' do
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
