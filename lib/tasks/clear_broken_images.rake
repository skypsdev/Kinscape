namespace :broken_images do
  desc 'Clears broken images from the new editor'
  task clear: :environment do
    dry_run = ENV['dryrun']

    ActionText::RichText.all.each do |rt|
      next if (content = rt.body).blank?

      record_name = rt.record.try(:name) ||
                    rt.record.try(:user_name)

      if rt.record.is_a?(Section)
        record_name = "Story##{rt.record.story.id} - #{rt.record.story.title}"
      end

      record_rep = "#{rt.record.class}##{rt.record.id} (#{record_name})"

      cleared_image_urls = []

      content.attachments.each do |attachment|
        attachable = attachment.attachable
        next unless attachable.is_a?(ActionText::Attachables::RemoteImage)

        fragment = content.fragment
                          .replace(ActionText::Attachment::SELECTOR) do |node|
          if node.attributes['url'].value == attachment.url &&
             # rubocop:disable Performance/StringInclude
             attachment.url.match(%r/\/rails\/active_storage/)
            # rubocop:enable Performance/StringInclude
            cleared_image_urls << attachment.url
            nil
          else
            node
          end
        end

        content.instance_variable_set '@fragment', fragment
      end

      rt.update(body: content) unless dry_run

      next if cleared_image_urls.blank?

      puts "Cleared image URL's on #{record_rep}:"
      cleared_image_urls.each do |url|
        puts url
      end
    end
    puts 'All Done!'
  end
end
