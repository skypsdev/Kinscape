namespace :user_identity do
  desc 'Converts old user identity information to kinship model'
  task migrate: :environment do
    User.where.not(avatar_id: nil).find_each do |user|
      user.kinships.each do |kinship|
        next if kinship.avatar.present?

        filename = user.avatar.filename || "#{user.name.parameterize}-avatar"
        begin
          kinship.avatar.attach(io: URI.parse(user.avatar.url).open,
                                filename: filename,
                                content_type: user.avatar.mimetype)
        rescue OpenURI::HTTPError
          puts 'Image does not exist'
        end

        kinship.nickname = user.nickname if kinship.nickname.blank?
        kinship.location = user.location if kinship.location.blank?
        kinship.birth_date = user.birth_date if kinship.birth_date.blank?
        kinship.address = user.address if kinship.address.blank?
        kinship.phone = user.phone if kinship.phone.blank?
        kinship.email = user.contact_email if kinship.email.blank?
        if kinship.birth_place.blank?
          kinship.birth_place = user.birth_place
        end

        kinship.save
      end
    end
    puts 'All Done!'
  end
end
