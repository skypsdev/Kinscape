# == Schema Information
#
# Table name: stripe_plans
#
#  id                :bigint           not null, primary key
#  plan_id           :string
#  active            :boolean
#  nickname          :string
#  currency          :string
#  amount            :integer
#  interval          :string
#  trial_period_days :integer
#  product           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe StripePlan, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:plan_id) }
    it { is_expected.to validate_uniqueness_of(:plan_id) }
  end
end
