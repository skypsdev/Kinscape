namespace :media_files do
  desc 'Fill the file info in DB'
  task fill_size: :environment do
    MediaFile.where(size: nil).each do |media_file|
      size = 0
      begin
        size = URI.parse(media_file.url).open.size
      rescue OpenURI::HTTPError
        puts "Not found #{media_file.url}"
        media_file.converted_urls.each_key do |format|
          format_url = media_file.cdn_url(format: format)
          begin
            size += URI.parse(format_url).open.size
          rescue OpenURI::HTTPError
            puts "Not found #{format_url}"
          end
        end
      end

      media_file.update_attribute(:size, size)
    end
  end
end
