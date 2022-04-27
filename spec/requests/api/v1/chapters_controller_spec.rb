require 'swagger_helper'

RSpec.describe Api::V1::ChaptersController, type: :request do
  let(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let!(:chapter) { create :chapter_family, chapterable: family, author: user }
  let(:id) { chapter.id }
  let(:object_id) { family.id }
  let(:object_type) { 'Family' }

  path '/api/v1/chapters' do
    get('list chapters') do
      include_context 'cookie'
      tags 'Chapter'

      parameter name: :object_id, in: :query, type: :string
      parameter name: :object_type, in: :query, type: :string, enum: %w[Family Kinship]

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].first['id']).to eq(chapter.id.to_s)
        end
      end
    end

    post('create chapter') do
      include_context 'cookie'
      tags 'Chapter'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          object_id: { type: :string },
          object_type: { type: :string, enum: %w[Family Kinship] },
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
          title: 'Brzeczyszczykiewicz',
          object_id: object_id,
          object_type: object_type
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['title']).to eq('Brzeczyszczykiewicz')
        end
      end
    end
  end

  path '/api/v1/chapters/{id}' do
    parameter name: :id, in: :path, type: :string

    patch('update chapter') do
      include_context 'cookie'
      tags 'Chapter'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          position: { type: :integer },
          object_id: { type: :string },
          object_type: { type: :string, enum: %w[Family Kinship] },
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
          title: 'Brzeczyszczykiewicz',
          object_id: object_id,
          object_type: object_type
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['title']).to eq('Brzeczyszczykiewicz')
        end
      end
    end

    delete('delete chapter') do
      include_context 'cookie'
      tags 'Chapter'

      parameter name: :object_id, in: :query, type: :string
      parameter name: :object_type, in: :query, type: :string, enum: %w[Family Kinship]

      response(204, 'successful') do
        before do
          expect(Chapter.count).to eq(1)
        end

        run_test! do
          expect(Chapter.count).to eq(0)
        end
      end
    end
  end

  # path '/api/v1/table_content_list' do
  #   get('table_content_list chapter') do
  #     include_context 'cookie'
  #     tags 'Chapter'
  #
  #     response(200, 'successful') do
  #       run_test! do
  #         expect(response.parsed_body).to eq('UPDATE_ME_RESPONSE')
  #       end
  #     end
  #   end
  # end
end
