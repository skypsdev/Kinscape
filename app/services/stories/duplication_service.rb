module Stories
  class DuplicationService < ApplicationService
    PREFIX = 'Copy'.freeze

    def initialize(story, community_type: false, user: nil, publication: nil)
      @story = story
      @community_type = community_type
      @dup_story = story.dup
      @user = user
      @publication = publication
    end

    def call
      dup_story.assign_attributes(
        title: title,
        appreciations_count: 0,
        comments_count: 0,
        original_story_id: (community_type || check_for_community ? story.id : nil),
        category_list: story.category_list,
        user_id: (user&.id || story.user_id)
      )
      dup_story.save
      dup_story.cover.attach(story.cover.blob)
      dup_story.publications.create(story_params) if check_for_community
      update_story_title
      CopySectionsJob.new(dup_story, story).enqueue(priority: 0)
      dup_story
    end

    private

    attr_reader :story, :community_type, :dup_story, :user, :publication

    def update_story_title
      return unless community_type
      return if story.reload.not_private_publications.any?
      return if story.title.start_with?('Copy ')

      story.update(title: "#{PREFIX} #{story.title}")
    end

    def title
      return "#{PREFIX} #{story.title}" unless community_type
      return story.title unless story.title.start_with?('Copy ')

      story.title.split[1..-1].join(' ')
    end

    def check_for_community
      return false unless publication

      admin_ids = publication.family.co_admins.ids.push(publication.family.admin_id)
      publication.family.default_access? && admin_ids.include?(user.id)
    end

    def story_params
      kinship = Kinship.find_by(user_id: dup_story.user_id, family_id: publication.family_id)
      { share_type: :community, family_id: publication.family_id, kinship_id: kinship.id }
    end
  end
end
