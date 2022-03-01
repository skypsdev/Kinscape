require 'filestack_config'

module Api
  module V1
    class KinshipsController < BaseController
      def show
        kinship = Kinship.includes(includes).find(params[:id])
        authorize! :read, kinship
        response_service.render(KinshipSerializer, kinship, options: { include: includes })
      end

      def show_by_family
        family = Family.find_by_uid!(params[:family_id])
        kinship = current_user.kinships.find_by(family_id: family.id)
        authorize! :read, kinship
        response_service.render(KinshipSerializer, kinship, options: { include: includes })
      end

      def update
        kinship = Kinship.find params[:id]
        authorize! :update, kinship
        kinship.update(kinship_params)
        response_service.render(KinshipSerializer, kinship)
      end

      def destroy
        kinship = Kinship.find(params[:id])
        authorize! :destroy, kinship
        stories = kinship.family.stories.where(user: kinship.user)
        Publication.where(family: kinship.family, story: stories).destroy_all
        kinship.destroy!
        response_service.render_no_content
      end

      def kinship_data
        family = Family.find_by_uid!(params[:family_id])
        kinship = family.kinships.find_by(user_id: params[:user_id])
        authorize! :read, kinship
        response_service.render(KinshipSerializer, kinship, options: { include: includes })
      end

      def upload_config
        # TODO: remove endpoint
        render json: FilestackConfig.upload
      end

      private

      def kinship_params
        params.permit(
          :avatar,
          :nickname,
          :location,
          :birth_date,
          :birth_place,
          :address,
          :phone,
          :email,
          :death_date,
          profile_attrs: {}
        )
      end
    end
  end
end
