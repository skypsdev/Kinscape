# == Schema Information
#
# Table name: appreciations
#
#  id               :bigint           not null, primary key
#  appreciable_type :string           not null
#  appreciable_id   :bigint           not null
#  user_id          :bigint           not null
#  reaction         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

RSpec.describe Appreciation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :appreciable }
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reaction) }

    context 'uniqueness' do
      subject { create(:appreciation) }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:appreciable_id, :appreciable_type) }
    end
  end
end
