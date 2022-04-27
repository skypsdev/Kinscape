module Chapters
  class CreationService < ApplicationService
    def initialize(object, params, current_user)
      @object = object
      @params = params
      @current_user = current_user
    end

    def call
      object.chapters.create(
        **sanitized_params,
        author_id: current_user.id,
        kinship: kinship
      )
    end

    private

    attr_reader :object, :params, :current_user

    def kinship
      return unless object.is_a?(Family)

      current_user.kinships.find_by(family: object)
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
