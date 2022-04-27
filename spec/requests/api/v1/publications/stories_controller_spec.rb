require 'swagger_helper'

RSpec.describe Api::V1::Publications::StoriesController, type: :request do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:family) { create :family, users: [user, another_user] }
  let(:story) { create :story, title: 'Old Title', user: user }
  let!(:publication) { create :publication, family: family, story: story, share_type: :community }
  let(:publication_id) { publication.id }

  path '/api/v1/publications/{publication_id}/story/duplicate' do
    parameter name: :publication_id, in: :path, type: :string

    post('duplicate story') do
      include_context 'cookie'
      tags 'Story'

      response(200, 'duplicate created') do
        before do
          expect(user.stories.count).to eq(1)
        end

        run_test! do
          expect(user.stories.count).to eq(2)
          new_story = user.stories.last
          expect(response.parsed_body['data']['id']).to eq(new_story.id)
        end
      end
    end
  end

  path '/api/v1/publications/{publication_id}/story/notify' do
    parameter name: :publication_id, in: :path, type: :string

    parameter name: :payload, in: :body, schema: {
      type: :object,
      properties: {
        changed_attr: {
          changed_generic: { type: :boolean },
          added_chapter: { type: :int }
        }
      }
    }
    let(:payload) do
      {
        changed_attr: {
          changed_generic: true,
          added_chapter: nil
        }
      }
    end

    post('notify contributors about new story changes') do
      include_context 'cookie'
      tags 'Story'
      before do
        stub_mandrill
      end

      response(204, 'successful') do
        run_test! do
          expect(all_emails.size).to eq(1)
        end
      end
    end
  end

  path '/api/v1/publications/{publication_id}/story/chapter_links' do
    parameter name: :publication_id, in: :path, type: :string

    get('list chapter_links') do
      include_context 'cookie'
      tags 'Story'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(story.id)
        end
      end
    end
  end

  path '/api/v1/publications/{publication_id}/story' do
    parameter name: :publication_id, in: :path, type: :string

    patch('update story') do
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

      response(200, 'story updated', save_request_example: :payload) do
        run_test! do
          expect(story.reload).to have_attributes(payload[:story].except(:cover, :categories))
          expect(story.category_list).to eq(payload[:story][:categories])
          expect(story.cover_url).to be_present
          expect(response.parsed_body['data']['id']).to eq(story.id)
        end
      end
    end

    delete('delete story') do
      include_context 'cookie'
      tags 'Story'

      before do
        create :section, author: another_user, story: story
      end

      response(204, 'successful') do
        let!(:story) { create :story, title: 'Old Title', user: user }
        before do
          stub_mandrill
          expect(Story.count).to eq 1
        end

        run_test! do
          expect(Story.count).to eq 0
          expect(all_emails.map(&:subject)).to contain_exactly('Story Deleted')
        end
      end
    end
  end
end
