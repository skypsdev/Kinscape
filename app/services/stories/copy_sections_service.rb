module Stories
  class CopySectionsService < ApplicationService
    def initialize(new_story, original_story)
      @new_story = new_story
      @original_story = original_story
      @copied_sections_ids = new_story.sections.pluck(:original_section_id)
    end

    def call
      original_story.sections.find_each do |section|
        next if copied_sections_ids.include?(section.id)

        new_story.sections << section.dup.tap do |dup_section|
          dup_section.original_section = section
          dup_section.rich_body = section.rich_body.dup
        end
      end
    end

    private

    attr_reader :new_story, :original_story, :copied_sections_ids
  end
end
