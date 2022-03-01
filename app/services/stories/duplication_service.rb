module Stories
  class DuplicationService < ApplicationService
    PREFIX = 'Copy'.freeze

    def initialize(story, community_type: false)
      @story = story
      @community_type = community_type
    end

    def call
      story.dup.tap do |dup_story|
        dup_story.assign_attributes(
          title: title,
          appreciations_count: 0,
          comments_count: 0,
          uuid: UuidService.generate
        )
        dup_story.original_story = story if community_type
        dup_story.cover.attach(story.cover.blob)
        dup_story.sections = sections

        dup_story.save
      end
    end

    private

    attr_reader :story, :community_type

    def sections
      story.sections.map do |section|
        section.dup.tap do |dup_section|
          dup_section.media_files = section.media_files.map(&:dup)
          dup_section.rich_body = section.rich_body.dup
        end
      end
    end

    def title
      return story.title if community_type

      "#{PREFIX} #{story.title}"
    end
  end
end
