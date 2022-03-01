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
        author_id: current_user.id
      )
    end

    private

    attr_reader :object, :params, :current_user

    def sanitized_params
      [:title].each do |key|
        next unless params[key]

        params[key] = ::SanitizerService.call(params[key])
      end
      params
    end
  end
end
