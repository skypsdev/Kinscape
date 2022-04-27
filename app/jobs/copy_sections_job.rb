class CopySectionsJob < ApplicationJob
  def perform(new_story, original_story)
    Stories::CopySectionsService.call(new_story, original_story)
  end
end
