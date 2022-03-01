require 'filestack_config'

module Api
  module V1
    class MediaFilesController < BaseController
      def create
        media_file = MediaFile.create(media_file_params)

        response_service.render(MediaFileSerializer, media_file)
      end

      def upload_config
        # TODO: remove endpoint
        render json: FilestackConfig.upload
      end

      private

      def media_file_params
        params.permit(
          :mimetype,
          :filename,
          :size,
          :url
        )
      end
    end
  end
end
