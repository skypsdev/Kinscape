module Api
  module V1
    class FollowersController < BaseController
      def index
        authorize! :read, family
        response_service.render_collection(
          KinshipSerializer,
          followers_query,
          options: {
            fields: { kinship: [:nickname, :avatar_url, :created_at, :family_id] }
          }
        )
      end

      private

      def followers_query
        kinships = if params[:showcase].present?
                     User.find_by(email: Showcase::USER_EMAIL).followers
                   else
                     current_user.followers
                   end
        if params[:query].present?
          kinships = kinships.where('LOWER(kinships.nickname) LIKE ?', "%#{params[:query].downcase}%")
        end
        kinships.order('nickname')
      end

      def family
        @family ||= if params[:showcase].present?
                      User.find_by(email: Showcase::USER_EMAIL).personal_family
                    else
                      current_user.personal_family
                    end
      end
    end
  end
end
