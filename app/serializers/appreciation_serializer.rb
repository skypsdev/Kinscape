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

class AppreciationSerializer < BaseSerializer
  set_id :id

  attributes(
    :reaction,
    :created_at,
    :appreciable_type,
    :appreciable_id
  )
end
