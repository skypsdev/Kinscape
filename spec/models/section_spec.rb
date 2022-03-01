# == Schema Information
#
# Table name: sections
#
#  id         :integer          not null, primary key
#  body       :text
#  story_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  media_type :string           not null
#  position   :integer          not null
#  author_id  :integer
#  title      :string
#  aws        :boolean
#

require 'spec_helper'

describe Section, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:story).touch(true) }
    it { is_expected.to have_many(:media_files) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:story) }
    it { is_expected.not_to validate_presence_of(:media_files) }
  end
end
