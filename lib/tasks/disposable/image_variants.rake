desc 'Create image variants for current images'
task image_variants: :environment do
  ActiveRecord::Base.transaction do
    Story.with_attached_cover.find_each do |story|
      next unless story.cover.attached?

      story.cover.variant(resize_to_limit: IMAGE_SIZE[:medium]).process
    end

    Family.with_attached_cover.find_each do |family|
      next unless family.cover.attached?

      family.cover.variant(resize_to_limit: IMAGE_SIZE[:medium]).process
    end

    Kinship.with_attached_avatar.find_each do |kinship|
      next unless kinship.avatar.attached?

      kinship.avatar.variant(resize_to_limit: IMAGE_SIZE[:medium]).process
      kinship.avatar.variant(resize_to_limit: IMAGE_SIZE[:thumb]).process
    end
  end
end
