require 'spec_helper'

describe Section, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:story).touch(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:story) }
  end
end
