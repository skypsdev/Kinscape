class ProcessImageVariantJob < ApplicationJob
  queue_as :default

  def perform(object, attachment_name, sizes)
    sizes.each do |size|
      object.send(attachment_name).variant(resize_to_limit: IMAGE_SIZE[size]).process
    end
  end
end
