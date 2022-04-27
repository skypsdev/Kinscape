require 'spec_helper'

RSpec.describe Appreciation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :appreciable }
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reaction) }

    context 'uniqueness' do
      subject(:model) { create(:appreciation) }

      it {
        expect(model).to validate_uniqueness_of(:user_id)
          .case_insensitive
          .scoped_to(:appreciable_id, :appreciable_type)
      }
    end
  end
end
