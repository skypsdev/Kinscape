# == Schema Information
#
# Table name: media_files
#
#  id             :bigint           not null, primary key
#  mimetype       :string
#  url            :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  filename       :text             default(""), not null
#  key            :string           default(""), not null
#  type           :string           not null
#  height         :integer
#  width          :integer
#  converted_urls :hstore
#  user_id        :integer
#  size           :integer
#  title          :string
#

class CoverImage < Image
  @formats = {
    small: { width: 250, height: 250 },
    medium: { width: 500, height: 500 },
    large: { width: 900, height: 900 }
  }

  def self.default
    ActionController::Base.helpers.asset_path('users.png')
  end
end
