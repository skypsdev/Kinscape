module Kinships
  class ActiveToOfflineService < ApplicationService
    def initialize(kinship, current_user)
      @kinship = kinship
      @current_user = current_user
      @user = kinship.user
      @family = kinship.family
    end

    def call
      ActiveRecord::Base.transaction do
        update_community_story_owner
        ::MailerService.call(:change_active_to_offline_member, params: { kinship: kinship, user: current_user })
        kinship.update!(user_id: nil, role: :offline_member)
      end
      kinship
    end

    private

    attr_reader :kinship, :user, :family, :current_user

    def update_community_story_owner
      user
        .stories
        .includes(:publications)
        .where.not(original_story_id: nil)
        .where(publications: { share_type: :community })
        .update_all(user_id: family.admin.id)
    end
  end
end
