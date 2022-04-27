require 'spec_helper'

describe StorySerializer do
  subject(:result) { described_class.new(story, options).serializable_hash }

  describe 'story' do
    let(:options) { { params: { current_user: user } } }
    let(:user) { create(:user) }
    let(:contributor) { create(:user) }
    let(:family) { create(:family, users: [user, contributor]) }
    let!(:story) { create :story, user: user }

    before do
      create :section, story: story, author: contributor
      create :section, story: story, author: contributor
      create :section, story: story, author: user
    end

    it 'renders story' do
      expect(result[:data][:attributes][:contributors_count]).to eq(1)
    end
  end
end
