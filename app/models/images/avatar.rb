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

class Avatar < Image
  @formats = {
    thumb: { width: 50, height: 50, fit: 'clip', align: 'faces' },
    small: { width: 150, height: 150, fit: 'clip', align: 'faces' },
    medium: { width: 250, height: 250, fit: 'clip', align: 'faces' },
    large: { width: 500, height: 500, fit: 'clip', align: 'faces' }
  }

  def self.default
    ActionController::Base.helpers.asset_path('avatar.svg')
  end
end
