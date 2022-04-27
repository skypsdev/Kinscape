module Api
  module V1
    class SignUpController < ::UsersController
      skip_forgery_protection

      private

      # hacky way of skipping recaptcha
      def verify_recaptcha_v3
        true
      end
    end
  end
end
