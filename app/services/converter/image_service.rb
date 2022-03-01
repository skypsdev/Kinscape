require 'filestack_config'

module Converter
  class ImageService
    class_attribute :test
    self.test = Rails.env.test?

    def initialize(media_file)
      @media_file = media_file
    end

    def convert
      if self.class.test
        @media_file
      else
        convert_image
      end
    end

    def convert_image
      converted_urls = {}

      @media_file.class.formats.each do |image_format, sizing|
        converted_urls[image_format] = convert_format(image_format, sizing)
      end

      @media_file.update_attribute(:converted_urls, converted_urls)
    end

    def convert_format(image_format, sizing)
      post_to_filepicker(convertation_url(image_format, sizing))['url']
    end

    private

    def convertation_url(image_format, sizing)
      sizing_query = sizing.reduce('') do |memo, (param, value)|
        memo + "&#{param}=#{value}"
      end

      @media_file.url +
        '/convert?rotate=exif' \
        "&key=#{Global.filepicker.api_key}" \
        "&storePath=%2F#{store_path(image_format)}%2F#{sizing_query}"
    end

    # URL format: "https://cdn.filestackcontent.com/{HANDLE}/convert?{PARAMS}"
    def post_to_filepicker(url)
      uri = URI.parse(url)
      file_handle = uri.path.split('/')[1]
      config = FilestackConfig.convert(file_handle)
      url += "&policy=#{config.policy}&signature=#{config.signature}"
      response = Faraday.post(url)
      JSON.parse(response.body)
    end

    def store_path(image_format)
      [@media_file.type.to_s.underscore.pluralize, image_format].join('%2F')
    end

    def extension
      File.extname(@media_file.key).presence || ".#{extension_from_mimetype}"
    end

    def extension_from_mimetype
      @media_file.try(:mimetype).try(:split, '/').try(:last) || 'png'
    end
  end
end
