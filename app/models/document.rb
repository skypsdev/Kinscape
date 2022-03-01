# == Schema Information
#
# Table name: media_files
#
#  id             :integer          not null, primary key
#  mimetype       :string
#  url            :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  filename       :text             default(""), not null
#  key            :string           default(""), not null
#  type           :string
#  height         :integer
#  width          :integer
#  converted_urls :hstore
#  user_id        :integer
#  size           :integer
#  title          :string
#

class Document < MediaFile
end
