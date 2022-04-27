module ActiveStorage
  class ProcessImageVariantJob < ApplicationJob
    def perform(attachment_id)
      attachment = ActiveStorage::Attachment.find_by(id: attachment_id)
      return unless attachment

      sizes = case attachment.record_type
              when 'Kinship' then [:medium, :thumb]
              when 'Family', 'Story' then [:medium]
              else []
              end

      sizes.each do |size|
        attachment.variant(resize_to_limit: IMAGE_SIZE[size]).process
      end
    end
  end
end
