# rubocop:disable all
namespace :aws do
  namespace :migration do
    task undo_section: :environment do
      Section.update_all aws: nil
      puts 'Done'
    end

    task section: :environment do
      require 'colorize'
      require 'progress_bar'

      puts 'You are running migration job for pictures from Filestack to AWS'
      puts

      sections_count = Section.all.size
      sections_migrated = Section.where(aws: true).size
      migration_percent = (sections_migrated / sections_count.to_f * 100).round(2)
      puts "Found sections: #{sections_count.to_s.colorize(:yellow)}"
      puts "Stories sections: #{sections_migrated}/#{sections_count.to_s.colorize(:yellow)}, #{migration_percent}%"

      def blob_from_file(filename)
        b = ActiveStorage::Blob.new filename: filename
        t = File.new(filename)
        b.upload t
        if b.service_url.nil?
          nil
          else
            b.save
            b
        end
      end

      def rich_text_filestack?(rich_text)
        rich_text.body.to_html.include?('cdn.filestackcontent.com')
      end

      def migrate_section!(s)
        require 'open-uri'

        if rich_text_filestack?(s.rich_body)
          puts "Found filestack images in section #{s.id}"

          doc = Nokogiri::HTML.fragment(s.rich_body.body.to_html)
          doc.xpath('.//action-text-attachment').each do |attachment|
            puts 'Downloading attachment from Filestack'
            url = FilestackConfig.with_view_config(attachment.attr('url'))
            filename = s.id.to_s
            File.open(filename, 'wb') do |file|
              file << URI.open(url).read
            end

            puts "Uploading to S3"
            s3_blob = blob_from_file(filename)

            puts "Fixing rich text body"

            attachment_html = ActionText::Attachment
                                .from_attachable(s3_blob, url: new_blob.signed_id, href: s3_blob.signed_id)
                                .to_html
            attachment.replace(attachment_html.to_html)
            FileUtils.remove(filename)
          end
          s.rich_body.update body: doc.to_html
          puts "Done #{s.id}".colorize(:green)
        else
          puts "Skipping".colorize(:yellow)
        end

      end

      current_section = 0
      Section.find_each do |s|
        current_section += 1
        puts "Section #{current_section} from #{sections_count}"
        begin
          migrate_section!(s) unless s.aws
        rescue StandardError => e
          puts "Something went wrong while migrating section: #{s.id}".colorize(:red)
          puts e.message
          puts e.backtrace
        end
      end
    end
  end
end
# rubocop:enable all
