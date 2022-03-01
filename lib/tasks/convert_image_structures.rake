namespace :convert_image_structures do
  desc 'Conversion tasks for the new STI image structuring'

  task cover_images: :environment do
    Image
      .where(id: Story.where.not(cover_image_id: nil)
      .select(:cover_image_id))
      .update_all(type: 'CoverImage')
  end

  task avatars: :environment do
    User.where(avatar_id: nil).where.not(old_avatar: [nil, '']).each do |u|
      print '.'
      u.create_avatar!(url: u.old_avatar)
    end
  end

  task family_covers: :environment do
    families = Family.where(cover_image_id: nil)

    families.where.not(old_cover: [nil, '']).each do |f|
      print '.'
      f.create_cover_image!(url: f.old_cover)
    end
  end
end
