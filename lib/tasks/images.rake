namespace :images do
  desc 'Makes sure all images are converted to proper formats'
  task convert: :environment do
    puts "Making sure all images are converted to #{Image.formats.keys} formats"
    Image.find_each { |image| ensure_image_converted image }
    puts 'Done'
  end

  def ensure_image_converted(image)
    image_service = Converter::ImageService.new(image)

    Image.formats.each do |image_format, sizing|
      format_key = image_format.to_s

      if image.converted_urls.key? format_key
        print '.'
      else
        print image_format[0]
        image.converted_urls[format_key] = image_service.convert_format(
          image_format,
          sizing
        )
      end
    end

    image.save if image.changed?
  rescue
    puts "\nConvertion failed for media file #{image.id}"
  end
end
