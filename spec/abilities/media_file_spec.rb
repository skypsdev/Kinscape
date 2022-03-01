require 'spec_helper'
require 'cancan/matchers'

describe 'Media file abilities' do
  subject(:ability) { Ability.new(user.reload) }

  let(:user) { create(:user) }
  let(:media_file) { create :media_file, user: user }

  context 'with paid member' do
    before do
      create :subscription,
             user: user,
             current_period_start: Time.current - 1.day,
             current_period_end: Time.current + 1.day
    end

    context 'when user is owner of the media file' do
      it { is_expected.to be_able_to(:manage, media_file) }
    end

    context 'when user is not owner of the media file' do
      let(:media_file) { create :media_file }

      it { is_expected.not_to be_able_to(:manage, media_file) }
    end
  end

  context 'when the user is not paid member' do
    it { is_expected.not_to be_able_to(:manage, media_file) }
  end
end
