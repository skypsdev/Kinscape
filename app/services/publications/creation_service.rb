module Publications
  class CreationService < ApplicationService
    def initialize(story, current_user, params)
      @story = story
      @current_user = current_user
      @families_ids = params[:families_ids]
      @publish_on = params[:publish_on]
      @share_type = params[:share_type] || 'shared'
    end

    def call
      families.map do |family|
        publication = family.publications.create(
          story: evaluate_story,
          publish_on: date,
          share_type: @share_type
        )
        return publication unless publication.persisted?

        ::Publications::NotifyService.call(publication, current_user)
        publication
      end
    end

    private

    attr_reader :publish_on, :current_user

    def families
      @families ||= current_user.families.find_all_by_uid(@families_ids)
    end

    def evaluate_story
      return @story if @share_type == 'shared'

      ::Stories::DuplicationService.call(@story, community_type: true)
    end

    def date
      return if publish_on.blank?
      return unless publish_on[:year] && publish_on[:month] && publish_on[:day]

      [publish_on[:year], publish_on[:month], publish_on[:day]].join(' ').to_date
    end
  end
end
