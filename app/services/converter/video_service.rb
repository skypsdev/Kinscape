module Converter
  class VideoService < ApplicationService
    def initialize(attachment:)
      @storage_attachment = attachment
      @blob = attachment.blob
      @filename = @blob.filename.base
      @tmp_path = "tmp/movie-#{@filename}.mp4"
      @rich_text = attachment.record.is_a?(ActionText::RichText) ? attachment.record : nil
    end

    def call
      return unless blob.video?

      blob.open(tmpdir: '/tmp') do |file|
        movie = FFMPEG::Movie.new(file.path)
        break if movie.video_codec == 'h264'

        movie.transcode(tmp_path, { video_codec: 'libx264', audio_codec: 'aac' }, loglevel: 'error')

        rich_text ? update_rich_text : update_active_storage
        FileUtils.remove(tmp_path)
      end
    end

    private

    attr_reader :storage_attachment, :blob, :tmp_path, :filename, :rich_text

    def new_blob
      @new_blob ||= ActiveStorage::Blob.create_and_upload!(
        io: File.open(tmp_path),
        filename: "#{filename}.mp4",
        content_type: 'video/mp4'
      )
    end

    def update_rich_text
      new_text_attachment = ActionText::Attachment
                            .from_attachable(new_blob, url: new_blob.signed_id, href: new_blob.signed_id)
                            .to_html
      document = Nokogiri::HTML.fragment(rich_text.body.to_html)
      document.xpath('.//action-text-attachment')
              .find { |element| element.attr('url') == blob.signed_id }
              .replace(new_text_attachment)
      rich_text.update!(body: document.to_html)
    end

    def update_active_storage
      storage_attachment.update!(blob: new_blob)
      blob.purge_later
    end
  end
end
