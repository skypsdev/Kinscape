module ActiveStorage
  class ConvertVideoJob < ApplicationJob
    queue_as :default

    def perform(attachment)
      ::Converter::VideoService.call(attachment: attachment)
    end
  end
end
