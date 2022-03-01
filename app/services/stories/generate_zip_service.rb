module Stories
  class GenerateZipService < ApplicationService
    def initialize(story)
      @story = story
      @download_dir_path = Rails.root.join('tmp', 'stories', "story-#{story.uid}")
      @zip_file = Tempfile.new
    end

    def call
      FileUtils.mkdir_p(download_dir_path) unless Dir.exist?(download_dir_path)
      Stories::GeneratePdfService.call(story: story, download_dir_path: download_dir_path)
      DownloadFilesService.call(documents: attachments, download_dir_path: download_dir_path)
      CompressFilesService.call(zip_file: zip_file, download_dir_path: download_dir_path)
      FileUtils.rm_rf(download_dir_path, secure: true)
      zip_file.path
    end

    private

    def attachments
      ids = ActionText::RichText.where(name: 'rich_body', record_type: 'Section', record_id: story.sections.ids)
      attachments = ActiveStorage::Attachment.where(name: 'embeds', record_type: 'ActionText::RichText', record_id: ids)
      attachments.filter_map do |attachment|
        next if attachment.content_type.include?('image')

        {
          url: attachment.url,
          filename: "#{attachment.filename}_#{attachment.id}"
        }
      end
    end

    attr_reader :story, :download_dir_path, :zip_file
  end
end
