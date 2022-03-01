# == Schema Information
#
# Table name: boxes
#
#  id         :integer          not null, primary key
#  name       :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vault_id   :integer
#  user_id    :integer
#  uuid       :bigint
#

require 'spec_helper'

RSpec.describe Box, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:name) }
end
