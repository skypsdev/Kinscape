require 'spec_helper'

describe Subscription, type: :model do
  let(:subscription) { create(:subscription) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '.canceled?' do
    context 'when cancel_at_period_end is present' do
      before do
        subscription.update(
          cancel_at_period_end: Time.zone.now
        )
      end

      it 'returns true' do
        expect(subscription.canceled?).to be true
      end
    end
  end

  describe '.trialing?' do
    context 'when status is trialing' do
      before do
        subscription.update(
          status: 'trialing'
        )
      end

      it 'returns true' do
        expect(subscription.trialing?).to be true
      end
    end
  end

  describe '.trial_days' do
    context 'when trial_end is present' do
      before do
        subscription.update(
          trial_end: 10.days.after
        )
      end

      it 'returns the different days' do
        expect(subscription.trial_days).to eq \
          (subscription.trial_end.to_date - Time.zone.now.to_date).to_i
      end
    end
  end

  describe '.active?' do
    context 'when status is active' do
      before do
        subscription.update(
          status: 'active'
        )
      end

      it 'returns true' do
        expect(subscription.active?).to be true
      end
    end
  end

  describe '.trial_past_due?' do
    context 'when trial_end is before now' do
      before do
        subscription.update(
          status: 'past_due'
        )
      end

      it 'returns true' do
        expect(subscription.trial_past_due?).to be true
      end
    end
  end

  describe '.plan_id' do
    before do
      subscription.update(
        billing_plan_data: { id: 'basic' }
      )
    end

    it 'returns the billing plan data id' do
      expect(subscription.plan_id).to eq 'basic'
    end
  end

  describe '.group_plan?' do
    context 'when plan_id is equal to STRIPE_GROUP_PLAN_ID' do
      before do
        ENV['STRIPE_GROUP_PLAN_ID'] = '1'
        allow(subscription).to receive(:plan_id).and_return('1')
      end

      it 'returns true' do
        expect(subscription.group_plan?).to be true
      end
    end
  end
end
