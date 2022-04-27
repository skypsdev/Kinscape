require 'swagger_helper'

RSpec.describe Api::V1::Publications::SectionsController, type: :request do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let!(:family) { create :family, users: [another_user, user] }
  let(:story) { create :story, user: user }
  let!(:section) { create :section, story: story, author: user }
  let(:publication_id) { story.private_publication.id }
  let(:id) { section.id }

  path '/api/v1/publications/{publication_id}/sections' do
    parameter name: :publication_id, in: :path, type: :string

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

      context 'not private publication' do
        let(:story) { create :story, user: another_user }
        let(:publication) { create :publication, story: story, family: family, share_type: share_type }
        let(:publication_id) { publication.id }

        response(200, 'successful', document: false) do
          let(:share_type) { :community }
          run_test!
        end

        response(401, 'unathorized', document: false) do
          let(:share_type) { :shared }
          run_test!
        end
      end
    end
  end

  path '/api/v1/publications/{publication_id}/sections/{id}' do
    parameter name: :publication_id, in: :path, type: :string
    parameter name: :id, in: :path, type: :string

    patch('update section') do
      include_context 'cookie'
      tags 'Section'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
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
