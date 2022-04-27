module Publications
  class CreationService < ApplicationService
    def initialize(story, current_user, params, send_mail: true)
      @story = story
      @current_user = current_user
      @params = params
      @send_mail = send_mail
      @publish_on = params[:publish_on]
      @families = Family.includes(:kinships).accessible_by(current_user.ability)
                        .where(kinships: { user_id: current_user.id })
                        .where.not(kinships: { role: :guest })
                        .where(id: params[:families_ids])
      @is_new_story = story.publications.count == 1 && story.publications.first.private_type?
    end

    def call
      publications = families.map do |family|
        share_type = family.access_type == 'default' ? params[:share_type] || 'shared' : family.access_type
        publication = family.publications.create(
          story: evaluate_story(share_type),
          publish_on: date,
          share_type: share_type,
          kinship: kinship(family)
        )
        return publication unless publication.persisted?

        ::Publications::NotifyService.call(publication, current_user) if send_mail
        publication
      end
      check_for_duplicate if publications.present?
      publications
    end

    private

    attr_reader :publish_on, :current_user, :story, :families, :params, :send_mail, :is_new_story

    def kinship(family)
      current_user.all_kinships.find_by(family: family)
    end

    def evaluate_story(share_type)
      return story unless share_type.to_s == 'community'

      ::Stories::DuplicationService.call(story, community_type: true)
    end

    def check_for_duplicate
      return unless params[:share_type] == 'shared' && is_new_story

      ::Stories::DuplicationService.call(story)
    end

    def date
      return if publish_on.blank?
      return unless publish_on[:year] && publish_on[:month] && publish_on[:day]

      [publish_on[:year], publish_on[:month], publish_on[:day]].join(' ').to_date
    end
  end
end
