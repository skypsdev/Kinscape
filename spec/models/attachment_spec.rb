# == Schema Information
#
# Table name: attachments
#
#  id               :integer          not null, primary key
#  media_file_id    :integer          not null
#  containable_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  containable_type :string           not null
#  position         :integer
#  comments_count   :integer
#  box_id           :integer
#  uuid             :bigint
#

require 'spec_helper'

describe Attachment, type: :model do
  it { is_expected.to belong_to :media_file }
  it { is_expected.to belong_to(:containable).optional }
end
