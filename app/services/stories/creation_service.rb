module Stories
  class CreationService < ApplicationService
    def initialize(params, current_user)
      @params = params.reject { |_k, v| v.blank? }
      @current_user = current_user
    end

    def call
      story = current_user.stories.create(
        **sanitized_params,
        publications_attributes: [
          { share_type: :private }
        ]
      )
      story.mark_as_read!(for: current_user)
      story
    end

    private

    attr_reader :current_user, :params

    def sanitized_params
      [:title, :description].each do |key|
        next unless params[key]

        params[key] = ::SanitizerService.call(params[key])
      end
      params[:categories].each { |category| ::SanitizerService.call(category) } if params[:categories].present?
      params
    end
  end
end
