module Stories
  class UpdatingService < ApplicationService
    def initialize(story, params)
      @story = story
      @params = params
    end

    def call
      story.update(sanitized_params)
      story
    end

    private

    attr_reader :story, :params

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
