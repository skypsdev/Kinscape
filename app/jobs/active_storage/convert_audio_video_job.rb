module ActiveStorage
  class ConvertAudioVideoJob < ApplicationJob
    def perform(attachment_id)
      ::Converter::AudioVideoService.call(attachment_id: attachment_id)
    end
  end
end
