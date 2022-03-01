require 'swagger_helper'

RSpec.describe Api::V1::SectionsController, type: :request do
  let(:user) { create :user }
  let!(:story) { create :story, user: user }
  let!(:section) { create :section, story: story, author: user }
  let(:story_id) { story.uid }
  let(:id) { section.id }

  path '/api/v1/stories/{story_id}/sections' do
    parameter name: 'story_id', in: :path, type: :string

    get('list sections') do
      include_context 'cookie'
      tags 'Section'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].first['id']).to eq(section.id.to_s)
        end
      end
    end

    post('create section') do
      include_context 'cookie'
      tags 'Section'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          media_type: { type: :string },
          position: { type: :integer },
          title: { type: :string },
          rich_body: {
            type: :object,
            properties: {
              body: { type: :string }
            }
          }
        }
      }
      let(:payload) do
        {
          media_type: 'text',
          position: 1,
          rich_body: { body: 'some body' },
          title: 'Brzeczyszczykiewicz'
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['title']).to eq('Brzeczyszczykiewicz')
        end
      end
    end
  end

  path '/api/v1/stories/{story_id}/sections/{id}' do
    parameter name: 'story_id', in: :path, type: :string
    parameter name: 'id', in: :path, type: :string

    patch('update section') do
      include_context 'cookie'
      tags 'Section'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          media_type: { type: :string },
          position: { type: :integer },
          title: { type: :string },
          rich_body: {
            type: :object,
            properties: {
              body: { type: :string }
            }
          }
        }
      }
      let(:payload) do
        {
          media_type: 'text',
          position: 1,
          rich_body: { body: 'some body' },
          title: 'Brzeczyszczykiewicz'
        }
      end

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['title']).to eq('Brzeczyszczykiewicz')
        end
      end
    end

    delete('delete section') do
      include_context 'cookie'
      tags 'Section'

      response(204, 'successful') do
        before do
          expect(Section.count).to eq(1)
        end

        run_test! do
          expect(Section.count).to eq(0)
        end
      end
    end
  end
end
