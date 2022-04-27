module Api
  module V1
    class FollowingsController < BaseController
      def index
        authorize! :read, Family
        response_service.render_collection(
          KinshipSerializer,
          followings_query,
          options: {
            fields: { kinship: [:nickname, :avatar_url, :created_at, :family_id] }
          }
        )
      end

      def show
        kinship = Kinship.find(params[:id])
        authorize! :read, kinship
        response_service.render(KinshipSerializer, kinship)
      end

      def destroy
        following = Kinship.find(params[:id])
        kinship = Kinship.find_by(user_id: current_user.id, family_id: following.family_id)
        authorize! :destroy, kinship
        kinship.destroy!
        response_service.render_no_content
      end

      private

      def followings_query
        kinships = if params[:showcase].present?
                     User.find_by(email: Showcase::USER_EMAIL).followings
                   else
                     current_user.followings
                   end
        if params[:query].present?
          kinships = kinships.where('LOWER(kinships.nickname) LIKE ?', "%#{params[:query].downcase}%")
        end
        kinships.order('nickname')
      end
    end
  end
end
