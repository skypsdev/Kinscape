module Sections
  class CreationService < ApplicationService
    def initialize(story, current_user, params)
      @story = story
      @current_user = current_user
      @params = params
    end

    def call
      section = story.sections.create(
        **sanitized_params,
        author: current_user
      )
      story.reload.mark_as_read! for: current_user
      section
    end

    private

    attr_reader :current_user, :story, :params

    def sanitized_params
      [:title].each do |key|
        next unless params[key]

        params[key] = ::SanitizerService.call(params[key])
      end
      params
    end
  end
end
