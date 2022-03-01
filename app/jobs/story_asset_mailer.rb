require Rails.root.join('lib/s3_store')
require 'zip'

class StoryAssetMailer
  def initialize(recipient:, story:)
    @recipient = recipient
    @story = story
  end

  def perform
    stored_file = S3Store.new(zip_file_stream, safe_title)
                         .store(method: :sysread)

    MailerService.call(
      :story_images,
      params: {
        recipient: @recipient,
        story: @story,
        file_url: stored_file.url
      },
      deliver_method: :deliver
    )
  end

  def zip_file_stream
    manifest = ZipManifest.build(media_files_for_story)
    build_zip_file(manifest)
  end

  def media_files_for_story
    (
      @story.sections.flat_map(&:media_files) +
        [@story.cover]
    ).compact
  end

  def should_send?
    media_files_for_story.any?
  end

  private

  def safe_title
    @story.title.gsub(/[^A-Za-z0-9]/, '-') + "-#{story.id}.zip"
  end

  def build_zip_file(zip_manifest)
    build_zip_file_stream(zip_manifest).tap(&:rewind)
  end

  def build_zip_file_stream(zip_manifest)
    Zip::OutputStream.write_buffer(::StringIO.new('')) do |zio|
      zip_manifest.each_file do |filename, contents|
        zio.put_next_entry(build_path(filename))
        zio.write(contents.read)
      end
    end
  end

  def build_path(filename)
    "#{@story.title}/#{filename}"
  end
end
