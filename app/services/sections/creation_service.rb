module Sections
  class CreationService < ApplicationService
    def initialize(publication, current_user, params)
      @publication = publication
      @story = publication.story
      @current_user = current_user
      @params = params
    end

    def call
      section = story.sections.create(
        **sanitized_params,
        author: current_user,
        kinship: kinship
      )
      story.reload.mark_as_read! for: current_user
      section
    end

    private

    attr_reader :current_user, :story, :params, :publication

    def kinship
      return unless publication.family

      current_user.all_kinships.find_by(family: publication.family)
    end

    def sanitized_params
      [:title].each do |key|
        next unless params[key]

        params[key] = ::SanitizerService.call(params[key])
      end
      params
    end
  end
end
