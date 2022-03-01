# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text             not null
#  commentable_type :string           not null
#  commentable_id   :integer          not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :bigint
#

require 'spec_helper'

describe Comment, type: :model do
  it_behaves_like 'uuidable'

  describe 'associations' do
    it { is_expected.to belong_to :commentable }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :publication }
    it { is_expected.to have_many :comments }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_presence_of :commentable }
    it { is_expected.to validate_presence_of :user }
  end
end
