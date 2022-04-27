# == Schema Information
#
# Table name: registration_codes
#
#  id               :integer          not null, primary key
#  code             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class RegistrationCode < ApplicationRecord
  validates :code, length: { is: 5 }
end
