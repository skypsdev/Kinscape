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

class Image < MediaFile
  after_create :enqueue_conversion

  def convert
    Converter::ImageService.new(self).convert
  end

  @formats = {
    collage: { width: 1280, fit: 'max' },
    medium: { width: 500, height: 500 }
  }

  class << self
    attr_reader :formats
  end

  private

  def enqueue_conversion
    delay.convert
  end
end
