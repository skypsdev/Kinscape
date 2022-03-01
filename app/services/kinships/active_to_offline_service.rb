module Kinships
  class ActiveToOfflineService < ApplicationService
    def initialize(kinship)
      @kinship = kinship
      @user = kinship.user
      @family = kinship.family
    end

    def call
      ActiveRecord::Base.transaction do
        update_shared_story_owner
        kinship.update!(user_id: nil, role: :member)
      end
      ::MailerService.call(:active_member_to_offline, params: { family: family, user: user })
      kinship
    end

    private

    attr_reader :kinship, :user, :family

    def update_shared_story_owner
      user.stories
          .includes(:publications)
          .where.not(original_story_id: nil)
          .where(publications: { share_type: :shared })
          .update_all(user_id: family.admin.id)
    end
  end
end
