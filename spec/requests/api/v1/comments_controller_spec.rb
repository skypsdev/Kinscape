require 'swagger_helper'

RSpec.describe Api::V1::CommentsController, type: :request do
  let(:story_user) { create :user }
  let(:user) { create :user }
  let(:family) { create :family, users: [story_user, user] }
  let(:chapter) { create :chapter_family, chapterable: family, author: user }
  let(:story) { create :story, user: story_user }
  let(:publication) { create :publication, story: story, family: family }
  let(:publication_id) { publication.id }
  let!(:comment) { create :comment, user: user, commentable: publication, body: 'Hello, World!' }

  path '/api/v1/comments' do
    post('create comment') do
      include_context 'cookie'
      tags 'Comment'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          body: { type: :string },
          commentable_type: { type: :string, enum: %w[Story Publication Comment Section Chapter] },
          commentable_id: { type: :string },
          parent: {
            parent_id: { type: :string },
            parent_type: { type: :string, enum: %w[Publication Kinship Family] }
          }
        },
        required: %w[body]
      }
      let(:payload) do
        {
          comment: {
            body: 'some body!',
            commentable_type: 'Publication',
            commentable_id: publication_id
          },
          parent: {
            parent_id: publication_id,
            parent_type: 'Publication'
          }
        }
      end

      response(200, 'successful', save_request_example: :payload) do
        before do
          stub_mandrill
        end

        run_test! do
          expect(response.parsed_body['data']['attributes']['body']).to(eq 'some body!')
        end
      end

      response(200, 'successful', save_request_example: :payload, document: false) do
        let(:payload) do
          {
            comment: {
              body: 'some body!',
              commentable_type: 'Chapter',
              commentable_id: chapter.id
            },
            parent: {
              parent_id: family.id,
              parent_type: 'Family'
            }
          }
        end
        before do
          stub_mandrill
        end

        run_test! do
          expect(response.parsed_body['data']['attributes']['body']).to(eq 'some body!')
        end
      end
    end
  end

  path '/api/v1/comments/{id}' do
    parameter name: 'id', in: :path, type: :string
    let(:id) { comment.id }

    delete('delete comment') do
      include_context 'cookie'
      tags 'Comment'

      response(204, 'successful') do
        before do
          expect(Comment.count).to eq 1
        end

        run_test! do
          expect(Comment.count).to eq 0
        end
      end
    end
  end
end
