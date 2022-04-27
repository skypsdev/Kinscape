module Api
  module V1
    class SignInController < ::SessionsController
      skip_forgery_protection
    end
  end
end
