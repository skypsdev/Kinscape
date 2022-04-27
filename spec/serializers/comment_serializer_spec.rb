require 'spec_helper'

describe CommentSerializer do
  subject(:result) { described_class.new(top_comment).serializable_hash }

  let(:publication) { create :publication }
  let(:top_comment) { create :comment, commentable: publication, top_commentable: publication }
  let!(:reply) { create :comment, commentable: top_comment, top_commentable: publication }

  it 'not include real family id' do
    expect(result[:data][:attributes][:body]).to eq(top_comment.body)
    expect(result[:data][:relationships][:comments][:data].first[:id]).to eq(reply.id)
  end
end
