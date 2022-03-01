require 'swagger_helper'

RSpec.describe Api::V1::PublicationsController, type: :request do
  let!(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let!(:story) { create(:story, user: user) }
  let!(:publication) { create :publication, story: story, family: family }
  let(:subscription) do
    create :subscription,
           user: user,
           current_period_start: Time.current - 1.day,
           current_period_end: Time.current + 1.day
  end
  let(:id) { publication.id }

  path '/api/v1/publications' do
    let!(:publication) { story.publications.create(family: family) }
    let!(:comment) { create :comment, publication: publication, commentable: publication }
    let!(:other_member_story) { create :story }
    let!(:other_member_publication) { other_member_story.publications.create(family: family) }
    let!(:timecapsule) { create(:publication, publish_on: Time.current + 1.month, family: family, story: story) }

    get('list publications') do
      tags 'Publication'
      include_context 'cookie'

      parameter name: :family_id, in: :query, type: :string
      parameter name: :publication_visibility, in: :query,
                schema: { type: :string, enum: %w[private_stories shared_stories] }
      parameter name: :categories, in: :query, type: :array
      parameter name: :author_id, in: :query, type: :string
      parameter name: :query, in: :query, type: :string
      parameter name: :sort_by, in: :query, type: :string, enum: %w[created_at updated_at title], default: 'updated_at'
      parameter name: :sort_direction, in: :query, type: :string, enum: %w[ASC DESC], default: 'DESC'
      let(:family_id) { family.id }
      let(:publication_visibility) { nil }
      let(:categories) { [] }
      let(:author_id) { nil }
      let(:query) { nil }
      let(:sort_by) { nil }
      let(:sort_direction) { nil }

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data'].pluck('id'))
            .to contain_exactly(publication.id.to_s, other_member_publication.id.to_s, timecapsule.id.to_s)
          expect(response.parsed_body['included'].pluck('id'))
            .to contain_exactly(story.uid, other_member_story.uid, comment.uid, family.uid)
        end
      end
    end
  end

  path '/api/v1/publications/{id}' do
    parameter name: 'id', in: :path, type: :string
    let(:id) { publication.id }
    let(:section) { create :section, story: story }
    let!(:publication_comment) { create :comment, publication: publication, commentable: publication }
    let!(:section_comment) { create :comment, publication: publication, commentable: section }
    let!(:comment_reply) { create :comment, publication: publication, commentable: section_comment }

    get('show publication') do
      tags 'Publication'
      include_context 'cookie'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(publication.id.to_s)
          expect(response.parsed_body['included'].pluck('id')).to contain_exactly(
            story.uid, family.uid, publication_comment.uid, section_comment.uid, comment_reply.uid, publication.id.to_s
          )
        end
      end
    end
  end

  path '/api/v1/stories/{story_id}/publications' do
    parameter name: 'story_id', in: :path, type: :string
    let(:story_id) { story.uid }

    post('create publication') do
      include_context 'cookie'
      it_behaves_like 'unauthorized - subscription missing'
      tags 'Publication'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          families_ids: { type: :array },
          publish_on: { type: :string },
          share_type: { type: :string, enum: Publication.share_types.keys }
        }
      }
      let(:payload) do
        {
          publication: {
            families_ids: families_ids,
            publish_on: publish_on,
            share_type: share_type
          }
        }
      end
      let(:publish_on) { { year: '3030', month: 'June', day: '1' } }
      let(:share_type) { 'shared' }
      let(:families_ids) { [family.uid] }

      context 'with share type' do
        response(200, 'successful', save_request_example: :payload) do
          before do
            subscription
            expect(Publication.count).to eq(1)
            expect(Story.count).to eq(1)
          end

          run_test! do
            expect(Publication.count).to eq(2)
            expect(Story.count).to eq(1)
            expect(response.parsed_body['errors']).to be_nil
            expect(story.reload.publications.first).to be_present
            publication = story.publications.shared_type.last
            expect(publication.share_type).to eq('shared')
          end
        end
      end

      context 'with community type' do
        let(:share_type) { 'community' }

        response(200, 'successful', save_request_example: :payload) do
          before do
            subscription
            expect(Publication.count).to eq(1)
            expect(Story.count).to eq(1)
          end

          run_test! do
            expect(Publication.count).to eq(2)
            expect(Story.count).to eq(2)
            expect(response.parsed_body['errors']).to be_nil
            expect(story.shared_stories).to be_present
            new_story = story.shared_stories.first
            expect(new_story.publications.first.share_type).to eq('community')
            expect(new_story.publications.first).to be_present
            expect(new_story).to have_attributes(
              story.attributes.except('id', 'created_at', 'updated_at', 'uuid', 'cover_image_id', 'original_story_id')
            )
          end
        end
      end
    end
  end

  path '/api/v1/stories/{story_id}/publications/{id}' do
    parameter name: :story_id, in: :path, type: :string
    parameter name: :id, in: :path, type: :string
    let(:story_id) { story.uid }

    delete('delete publication') do
      include_context 'cookie'
      tags 'Publication'

      response(204, 'successful') do
        before do
          expect(Publication.count).to eq(1)
        end

        run_test! do
          expect(Publication.count).to eq(0)
        end
      end
    end
  end
end
