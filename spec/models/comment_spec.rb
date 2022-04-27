require 'spec_helper'

describe Comment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :commentable }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :comments }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_presence_of :commentable }
    it { is_expected.to validate_presence_of :user }
  end
end
