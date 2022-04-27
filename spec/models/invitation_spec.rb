require 'spec_helper'

describe Invitation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:family) }
    it { is_expected.to belong_to(:sender) }
    it { is_expected.to belong_to(:recipient).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }

    it 'validates uniqueness of email in a family' do
      existing = create(:invitation)
      duplicate = build(
        :invitation, email: existing.email, family: existing.family
      )

      duplicate.save

      expect(duplicate.errors[:email]).to eq ['has already been taken']
    end
  end
end
