require 'swagger_helper'

RSpec.describe Api::V1::PublicationsController, type: :request do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:family) { create :family, users: [user, another_user] }
  let(:family2) { create :family, users: [user, another_user] }
  let(:story) { create :story, user: user, category_list: ['initial_tag'] }
  let(:timecapsule_story) { create :story, user: user }
  let!(:publication) { create :publication, story: story, family: family, share_type: :shared }
  let(:id) { publication.id }

  path '/api/v1/publications' do
    let(:other_member_story) { create :story, user: another_user }
    let!(:other_member_publication) { create :publication, story: other_member_story, family: family }
    let!(:timecapsule) do
      create(:publication, publish_on: Time.current + 1.month, family: family, story: timecapsule_story)
    end

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
            .to contain_exactly(story.id, other_member_story.id, family.id, timecapsule_story.id)
        end
      end
    end
  end

  path '/api/v1/publications/{id}' do
    parameter name: 'id', in: :path, type: :string
    let(:id) { publication.id }
    let(:section) { create :section, story: story }
    let!(:publication_comment) { create :comment, top_commentable: publication, commentable: publication }
    let!(:section_comment) { create :comment, top_commentable: publication, commentable: section }
    let!(:comment_reply) { create :comment, top_commentable: publication, commentable: section_comment }

    get('show publication') do
      tags 'Publication'
      include_context 'cookie'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(publication.id.to_s)
          expect(response.parsed_body['included'].pluck('id')).to contain_exactly(
            story.id.to_s, family.id.to_s, publication_comment.id.to_s, section_comment.id.to_s,
            user.private_family.id.to_s, comment_reply.id.to_s, publication.id.to_s
          )
        end
      end
    end
  end

  path '/api/v1/publications' do
    post('create publication') do
      include_context 'cookie'
      tags 'Publication'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :string, description: 'id of publication (can not be community type)' },
          families_ids: { type: :array },
          publish_on: { type: :string },
          share_type: { type: :string, enum: Publication.share_types.keys }
        }
      }
      let(:payload) do
        {
          publication: {
            id: story.private_publication.id,
            families_ids: families_ids,
            publish_on: publish_on,
            share_type: share_type
          }
        }
      end
      let(:publish_on) { { year: '3030', month: 'June', day: '1' } }
      let(:share_type) { 'shared' }
      let(:families_ids) { [family.id] }

      context 'with share type' do
        response(200, 'successful', save_request_example: :payload) do
          before do
            expect(Publication.count).to eq(2)
            expect(Story.count).to eq(1)
          end

          run_test! do
            expect(Publication.count).to eq(3)
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
            expect(Publication.count).to eq(2)
            expect(Story.count).to eq(1)
          end

          run_test! do
            expect(Publication.count).to eq(3)
            expect(Story.count).to eq(2)
            expect(response.parsed_body['errors']).to be_nil
            expect(story.shared_stories).to be_present
            new_story = story.shared_stories.first
            expect(new_story.publications.first.share_type).to eq('community')
            expect(new_story.publications.first).to be_present
            expect(new_story).to have_attributes(
              story
              .attributes
              .except('id', 'created_at', 'updated_at', 'cover_image_id', 'original_story_id', 'title')
            )
          end
        end
      end
    end
  end

  path '/api/v1/publications/{id}' do
    parameter name: :id, in: :path, type: :string

    delete('delete publication') do
      include_context 'cookie'
      tags 'Publication'

      response(204, 'successful') do
        before do
          stub_mandrill
          expect(Publication.count).to eq(2)
        end

        run_test! do
          expect(Publication.count).to eq(1)
          expect(all_emails.map(&:subject).uniq).to contain_exactly('Story Deleted')
          expect(all_emails.size).to eq(2)
        end
      end
    end
  end
end
