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

      if params[:categories].present?
        params[:categories] = params[:categories].uniq
        params[:categories].each { |category| ::SanitizerService.call(category.strip) }
        params[:category_list] = params.delete(:categories)
      end
      params
    end
  end
end
