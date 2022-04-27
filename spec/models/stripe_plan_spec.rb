require 'spec_helper'

describe StripePlan, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:plan_id) }
    it { is_expected.to validate_uniqueness_of(:plan_id) }
  end
end
