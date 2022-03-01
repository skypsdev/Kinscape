namespace :sections_titles do
  desc 'Extracts titles from sections body'
  task extract: :environment do
    EncryptedActionText::Content.renderer = ActionText::Content.renderer

    Section.all.each do |section|
      next if section.headers.blank?

      section.update(title: section.headers.first)
      puts "Section #{section.id}: Added title -> #{section.reload.title}"
    end

    puts 'All Done!'
  end
end
