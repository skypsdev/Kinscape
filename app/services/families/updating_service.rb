module Families
  class UpdatingService < ApplicationService
    def initialize(family, params)
      @family = family
      @params = params
    end

    def call
      family.update!(sanitized_params)
      family
    end

    private

    attr_reader :family, :params

    def sanitized_params
      params[:profile] = params[:profile][:body] if params[:profile]
      [:name, :motto, :description].each do |key|
        next unless params[key]

        params[key] = ::SanitizerService.call(params[key])
      end
      params
    end
  end
end
