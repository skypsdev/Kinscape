require 'spec_helper'
require 'cancan/matchers'

describe 'Manage Story ability' do
  subject(:ability) { Ability.new(user.reload) }

  let(:user) { create :user }
  let(:story_owner) { create :user }
  let(:family) { create :family, name: 'Some family', users: [user, story_owner] }
  let(:story) { create :story, user: story_owner }

  before { create :publication, story: story, family: family, publish_on: publish_on }

  context 'with nil' do
    let(:publish_on) { nil }

    it { is_expected.to be_able_to(:read, story) }
  end

  context 'with time current' do
    let(:publish_on) { Time.current }

    it { is_expected.to be_able_to(:read, story) }
  end

  context 'with time in the future' do
    let(:publish_on) { Time.zone.now + 1.week }

    it { is_expected.not_to be_able_to(:read, story) }
  end
end
