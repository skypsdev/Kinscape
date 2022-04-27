require 'spec_helper'

RSpec.describe CopySectionsJob, type: :job do
  subject(:job) { described_class.perform_now(new_story, original_story) }

  let(:user) { create :user }
  let(:original_story) { create :story, user: user }
  let!(:new_story) { create :story, user: user, original_story: original_story }

  before { create :section, author: user, story: original_story }

  it 'create sections in new_story' do
    expect { job }.to change(Section, :count).by(1)
  end
end
