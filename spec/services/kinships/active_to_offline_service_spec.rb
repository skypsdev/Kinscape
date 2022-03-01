require 'spec_helper'

describe Kinships::ActiveToOfflineService do
  subject(:result) { described_class.call(kinship) }

  let(:user) { create :user }
  let(:admin) { create :user }
  let(:story) { create :story, user: user }
  let!(:publications) do
    stub_mandrill
    ::Publications::CreationService.call(story, user, { share_type: :shared, families_ids: [family.uid] })
  end
  let(:copied_story) { publications.first.story }
  let(:family) { create :family, users: [admin, user] }
  let(:kinship) { user.kinships.find_by(family: family) }

  it 'changes active member to offline member' do
    expect { result }.to change { copied_story.reload.user_id }
      .from(user.id)
      .to(admin.id)
    expect(kinship.reload.user_id).to eq(nil)
    expect(kinship.role).to eq('member')
  end
end
