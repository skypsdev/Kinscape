class TemplatesController < ApplicationController
  include HighVoltage::StaticPage

  layout false

  private

  def page_finder_factory
    TemplateFinder
  end

  class TemplateFinder < HighVoltage::PageFinder
    def content_path
      'templates/'
    end
  end
end
