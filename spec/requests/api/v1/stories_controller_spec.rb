require 'swagger_helper'

RSpec.describe Api::V1::StoriesController, type: :request do
  let(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let!(:story) { create :story, families: [family], title: 'Old Title', user: user }
  let(:subscription) do
    create :subscription,
           user: user,
           current_period_start: Time.current - 1.day,
           current_period_end: Time.current + 1.day
  end
  let(:id) { story.uid }

  path '/api/v1/stories/{id}/duplicate' do
    parameter name: 'id', in: :path, type: :string

    post('duplicate story') do
      include_context 'cookie'
      it_behaves_like 'unauthorized - subscription missing'
      tags 'Story'

      response(200, 'duplicate created') do
        before do
          subscription
          expect(user.stories.count).to eq(1)
        end

        run_test! do
          expect(user.stories.count).to eq(2)
          new_story = user.stories.last
          expect(response.parsed_body['data']['id']).to eq(new_story.uid)
        end
      end
    end
  end

  path '/api/v1/stories/{id}/notify' do
    parameter name: 'id', in: :path, type: :string

    post('notify contributors about new story changes') do
      include_context 'cookie'
      tags 'Story'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(story.uid)
        end
      end
    end
  end

  path '/api/v1/stories/{id}/chapter_links' do
    parameter name: 'id', in: :path, type: :string

    get('list chapter_links') do
      include_context 'cookie'
      tags 'Story'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(story.uid)
        end
      end
    end
  end

  path '/api/v1/stories/{id}/upload_config' do
    parameter name: 'id', in: :path, type: :string

    get('filestack config') do
      deprecated true
      include_context 'cookie'
      tags 'Story'

      response(200, 'successful') do
        run_test! do
          expect(response.body).to eq('{}')
        end
      end
    end
  end

  path '/api/v1/stories' do
    post('create story') do
      include_context 'cookie'
      it_behaves_like 'unauthorized - subscription missing'
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

      response(401, 'unauthorized') do
        run_test! do
          expect(response.parsed_body['message']).to eq('unauthorized')
        end
      end

      response(200, 'story created', save_request_example: :payload) do
        before do
          subscription
          expect(user.stories.count).to eq(1)
        end

        run_test! do
          expect(user.stories.count).to eq(2)
          new_story = user.stories.find_by(title: title)
          expect(new_story).to have_attributes(payload[:story].except(:cover))
          expect(new_story.cover_url).to be_present
          expect(response.parsed_body['data']['id']).to eq(new_story.uid)
        end
      end
    end
  end

  path '/api/v1/stories/{id}' do
    parameter name: 'id', in: :path, type: :string

    delete('delete story') do
      include_context 'cookie'
      tags 'Story'

      response(204, 'successful') do
        let!(:story) { create :story, title: 'Old Title', user: user }
        before do
          expect(Story.count).to eq 1
        end

        run_test! do
          expect(Story.count).to eq 0
        end
      end
    end
  end
end
