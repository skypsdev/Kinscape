module Convertable
  extend ActiveSupport::Concern

  included do
    after_create :convert
    delegate :converted_urls, to: :convert_media_file
  end

  private

  def convert
    convert_media_file.convert
  end

  def convert_media_file
    @convert_media_file ||= Converter::MediaFileService.new(self)
  end
end
