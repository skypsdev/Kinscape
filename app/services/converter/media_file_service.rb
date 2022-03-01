module Converter
  class MediaFileService
    class_attribute :test
    self.test = Rails.env.test?

    def initialize(media_file)
      @media_file = media_file
    end

    def convert
      if self.class.test
        @media_file
      else
        Zencoder::Job.create(input: @media_file.url, outputs: outputs)
      end
    end

    # This is a bit surprising because it is overriding the database accessor.
    # If this followed the pattern of the ConvertImage and wrote this accessor
    # after conversion that may be more clear.
    def converted_urls
      urls = @media_file.convert_formats.inject({}) do |accumulator, format|
        accumulator[format] = converted_url(format)
        accumulator
      end

      return urls unless requires_thumbnail?

      urls.merge(
        thumbnail: thumbnail_url
      )
    end

    def file_size
      uri = URI(@media_file.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.request_head(uri.path)['content-length']
    rescue
      nil
    end

    private

    def converted_url(extension)
      File.join(
        @media_file.s3_base,
        @media_file.s3_bucket,
        converted_path(extension)
      )
    end

    def outputs
      formats = @media_file.convert_formats.map do |format|
        {
          format: format,
          public: true,
          url: converted_s3_url(format),
          credentials: zencoder_credential_set
        }
      end

      return formats unless requires_thumbnail?

      formats << thumbnails
    end

    def thumbnails
      {
        thumbnails: {
          credentials: zencoder_credential_set,
          public: true,
          label: 'thumbnail',
          filename: thumbnail_filename,
          size: '500x500',
          base_url: thumbnail_base_url
        }
      }
    end

    def thumbnail_url
      File.join(
        @media_file.s3_base,
        @media_file.s3_bucket,
        'attic',
        "#{thumbnail_filename}.png"
      )
    end

    def thumbnail_base_url
      "s3://#{@media_file.s3_bucket}/attic"
    end

    def thumbnail_filename
      "#{@media_file.id}-thumbnail"
    end

    def converted_path(format)
      path = @media_file.key.split('/')
      filename = CGI.escape(path.pop)
      extension = File.extname(filename)
      path << filename.gsub!(/#{extension}$/, "-converted.#{format}")
      File.join(path)
    end

    def converted_s3_url(format)
      "s3://#{@media_file.s3_bucket}/#{converted_path(format)}"
    end

    def requires_thumbnail?
      @media_file.type == 'Video'
    end

    def zencoder_credential_set
      ENV.fetch('ZENCODER_CREDENTIALS', 's3_overly_permissive')
    end
  end
end
