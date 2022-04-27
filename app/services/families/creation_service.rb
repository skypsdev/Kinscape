module Families
  class CreationService < ApplicationService
    def initialize(current_user, params)
      @current_user = current_user
      @params = params
    end

    def call
      Family.create(
        **sanitized_params,
        kinships_attributes: [{
          role: :admin,
          nickname: current_user.name,
          user_id: current_user.id
        }]
      )
    end

    private

    attr_reader :params, :current_user

    def sanitized_params
      params[:profile] = params[:profile][:body] if params[:profile]
      [:name, :motto, :family_type, :description].each do |key|
        next unless params[key]

        params[key] = ::SanitizerService.call(params[key])
      end
      params
    end
  end
end
