module Converter
  class AudioVideoService < ApplicationService
    def initialize(attachment_id:)
      @storage_attachment = ActiveStorage::Attachment.find_by(id: attachment_id)
      @blob = @storage_attachment&.blob
    end

    def call
      return true unless blob
      return true unless blob.video? || blob.audio?

      blob.open(tmpdir: '/tmp') do |file|
        @footage = FFMPEG::Movie.new(file.path)

        break if @footage.video_codec && @footage.video_codec == 'h264'
        break if @footage.video_codec.nil? && @footage.audio_codec == 'aac'

        @footage.transcode(tmp_path, { video_codec: 'libx264', audio_codec: 'aac' }, loglevel: 'error')
        rich_text ? update_rich_text : update_active_storage
        FileUtils.remove(tmp_path, force: true)
      end
    end

    private

    attr_reader :storage_attachment, :blob

    def rich_text
      @rich_text ||= if storage_attachment.record.is_a?(ActionText::RichText)
                       EncryptedActionText::RichText.find_by(id: storage_attachment.record_id)
                     end
    end

    def tmp_path
      @tmp_path ||= "tmp/footage-#{filename}"
    end

    def filename
      @filename ||= "#{blob.filename.base}.#{@footage.video_codec ? :mp4 : :aac}"
    end

    def new_blob
      @new_blob ||= ActiveStorage::Blob.create_and_upload!(
        io: File.open(tmp_path),
        filename: filename,
        content_type: @footage.video_codec ? 'video/mp4' : 'audio/aac'
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
