require 'spec_helper'

describe Stories::NotificationService do
  let!(:author)     { create :user }
  let(:family)      { create :family, users: [author] }
  let!(:story)      { create :story, user: author }

  before do
    create_list(:kinship, 4, family: family) do |kinship|
      kinship.user = create(:user)
    end
    stub_mandrill
  end

  describe '#notify_contribution' do
    subject(:result) { described_class.notify_contribution(publication, user) }

    let(:publication) { create :publication, story: story, family: family }

    context 'for a user belonging to a family story is shared to' do
      let(:user) { author }

      it 'sends emails' do
        result
        expect(all_emails.size).to eq(4)
      end
    end
  end

  describe '#notify_time_capsule_released' do
    subject(:result) { described_class.notify_time_capsule_released }

    before do
      build(
        :publication,
        publish_on: 1.day.ago,
        notified_at: nil,
        story: story,
        family: family
      ).save validate: false
    end

    context 'when the publish date has passed and notification not sent' do
      it 'sends emails' do
        result
        expect(all_emails.size).to eq(4)
      end
    end
  end

  describe '#notify_appreciation' do
    subject(:result) { described_class.notify_appreciation(publication, user) }

    let!(:publication) { create :publication, family: family, story: story }

    context 'when the user is the author' do
      let(:user) { author }

      it 'does not send the email' do
        result
        expect(all_emails.size).to eq(0)
      end
    end

    context 'when the user is not the author' do
      let(:user) { create :user }

      it 'sends the email to the author' do
        result
        expect(all_emails.size).to eq(1)
      end
    end
  end
end
