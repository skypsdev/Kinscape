module Sections
  class UpdatingService < ApplicationService
    def initialize(section, current_user, params)
      @section = section
      @params = params
      @current_user = current_user
    end

    def call
      section.update(sanitized_params)
      section.story.reload.mark_as_read! for: current_user
      section
    end

    private

    attr_reader :section, :params, :current_user

    def sanitized_params
      params[:rich_body] = params[:rich_body][:body] if params[:rich_body].present?
      [:title].each do |key|
        next unless params[key]

        params[key] = ::SanitizerService.call(params[key])
      end
      params
    end
  end
end
