module Chapters
  class UpdatingService < ApplicationService
    def initialize(chapter, params)
      @chapter = chapter
      @params = params
    end

    def call
      chapter.update(sanitized_params)
      chapter
    end

    private

    attr_reader :chapter, :params

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
