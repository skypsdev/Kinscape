namespace :sections do
  desc 'Fixes invalid HTML produced by buggy medium-editor'
  task clean_body: :environment do
    Story.order(:id).all.each do |story|
      changed_sections = []
      story.sections.where("media_type = 'text'").each do |section|
        body = section.body.delete "\n"

        next if body.empty?

        parsed_body = Nokogiri::HTML.fragment(body)

        parsed_body.css('br').each(&:remove)

        parsed_body.children.each do |node|
          if node.instance_of?(Nokogiri::XML::Text)
            node.replace("<p>#{node.text}</p>")
            changed_sections.push section
          end
          if node.text.blank?
            node.remove
            changed_sections.push section
          end
        end

        section.body = parsed_body.to_html
      end

      next if changed_sections.size.zero?

      changed_sections.each(&:save)
    end
  end

  desc 'Converts old editor sections to the new editor'
  task convert_to_rich: :environment do
    EncryptedActionText::Content.renderer = ActionText::Content.renderer

    Section.where.not(media_type: 'text').each do |section|
      section.rich_body.body ||= EncryptedActionText::Content.new
      section.rich_body = section.rich_body
                                 .body
                                 .append_attachables(section.media_files)
      section.rich_body = "#{section.rich_body}\n#{section.body}"
      section.save
    end

    Section.where.not(body: nil).where(media_type: 'text').each do |section|
      section.rich_body.body ||= EncryptedActionText::Content.new(section.body)
      section.save
    end
  end
end
