module Api
  module V1
    class UsersController < BaseController
      def update
        current_user.update(user_params)
        response_service.render(UserSerializer, current_user)
      end

      protected

      def user_params
        params.permit(
          :first_name,
          :last_name,
          *User::METADATA_FIELDS
        )
      end
    end
  end
end
