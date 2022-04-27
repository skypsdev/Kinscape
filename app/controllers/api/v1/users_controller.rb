module Api
  module V1
    class UsersController < BaseController
      def update
        return response_service.render_forbidden unless authenticated_user

        current_user.update(user_params)
        response_service.render(UserSerializer, current_user)
      end

      private

      def user_params
        params.permit(
          :first_name,
          :last_name,
          :email,
          :password,
          :password_confirmation,
          onboarding: {}
        )
      end

      def authenticated_user
        return true unless params.key?(:password) || params.key?(:email)

        current_user.authenticated?(params[:current_password])
      end
    end
  end
end
