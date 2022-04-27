require 'swagger_helper'

RSpec.describe Api::V1::StoriesController, type: :request do
  let(:user) { create :user }
  let(:family) { create :family, users: [user] }
  let!(:story) { create :story, title: 'Old Title', user: user }
  let(:publication_id) { story.private_publication.id }

  path '/api/v1/story' do
    post('create story') do
      include_context 'cookie'
      tags 'Story'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          categories: { type: :array },
          description: { type: :string },
          start_year: { type: :string },
          start_month: { type: :string },
          start_day: { type: :string },
          end_year: { type: :string },
          end_month: { type: :string },
          end_day: { type: :string },
          cover: { type: :string },
          is_range: { type: :boolean }
        }
      }
      let(:payload) do
        {
          story: {
            title: title,
            description: 'some test description',
            start_year: '2020',
            start_month: 'January',
            start_day: '1',
            end_year: '2020',
            end_month: 'February',
            end_day: '2',
            cover: image_blob.signed_id,
            is_range: true,
            categories: %w[category1 category2 category3]
          }
        }
      end
      let(:title) { 'some title' }
      let(:image_blob) { create_file_blob }

      response(200, 'story created', save_request_example: :payload) do
        before do
          expect(user.stories.count).to eq(1)
        end

        run_test! do
          expect(user.stories.count).to eq(2)
          new_story = user.stories.find_by(title: title)
          expect(new_story).to have_attributes(payload[:story].except(:cover, :categories))
          expect(new_story.category_list).to eq(payload[:story][:categories])
          expect(new_story.cover_url).to be_present
          expect(response.parsed_body['data']['id']).to eq(new_story.id)
        end
      end
    end
  end
end
