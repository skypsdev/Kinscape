require 'swagger_helper'

RSpec.describe Api::V1::Publications::CommentsController, type: :request do
  let(:story_user) { create :user }
  let(:user) { create :user }
  let(:family) { create :family, users: [story_user, user] }
  let(:story) { create :story, user: story_user }
  let(:publication) { create :publication, story: story, family: family }
  let(:publication_id) { publication.id }
  let!(:comment) { create :comment, user: user, commentable: publication, body: 'Hello, World!' }

  path '/api/v1/publications/{publication_id}/comments' do
    parameter name: 'publication_id', in: :path, type: :string

    post('create comment') do
      include_context 'cookie'
      tags 'Comment'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          body: { type: :string },
          commentable_type: { type: :string, enum: %w[Story Publication Comment Section] },
          commentable_id: { type: :string }
        },
        required: %w[body]
      }
      let(:payload) do
        {
          comment: {
            body: 'some body!',
            commentable_type: 'Publication',
            commentable_id: publication_id
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
    end
  end

  path '/api/v1/publications/{publication_id}/comments/{id}' do
    parameter name: 'publication_id', in: :path, type: :string
    parameter name: 'id', in: :path, type: :string
    let(:id) { comment.uid }

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
