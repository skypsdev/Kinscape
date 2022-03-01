namespace :utilities do
  desc 'Housekeeping tasks'

  # Reprocesses images
  # ------------------------------------------------------------
  # By default, only processes images with converted_url's that
  # are missing any of the keys defined in the class
  # Passing true will reprocess all images
  task convert_images: :environment do
    image_str = ENV['CLASS']

    if image_str.blank?
      puts 'Please specify a class to process images for ' \
           '(Image, Crest, Avatar, CoverImage).'
      exit
    end

    force = ENV['FORCE']
    klass = image_str.constantize
    unless force
      # add in
      klass.formats.each do |k, _v|
        # klass = klass.where("not converted_urls ? :key", key: k.to_s)
        klass = klass.where("converted_urls IS NULL
            OR
            converted_urls @> hstore(:key, NULL)
            OR NOT
            converted_urls ? :key", key: k.to_s)
      end
    end

    images = klass.all
    puts "Converting #{images.count} #{klass.to_s.pluralize}..."
    # images.map(&:convert)
    images.map do |image|
      puts "Converting ID #{image.id}: #{image.filename}"
      image.convert
    end
  end

  desc 'Find all users over past X days without Stripe subscription'
  task :users_without_subscription, [:created_at] => [:environment] do |_, args|
    if args[:created_at]
      date = DateTime.parse(args[:created_at])
      users = User.where('users.created_at > ?', date)
    else
      users = User
    end

    users = users.includes(:subscriptions)
                 .where(subscriptions: { id: nil })

    users.each do |user|
      puts "Failed User ID: #{user.id},\
                   Email: #{user.email},\
                   Name: #{user.name}"
    end
  end
end
