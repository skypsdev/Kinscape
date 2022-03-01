module IntercomDataHelper
  def intercom_script_tag_for_current_user
    return unless Global.intercom.enabled
    return unless signed_in?

    intercom_script_tag(user_data)
  end

  def user_data
    {
      app_id: ENV['INTERCOM_APP_ID'] || Global.intercom.app_id,
      user_id: user.id,
      email: user.email,
      name: user.name,
      created_at: user.created_at,
      custom_data: {
        # stories: user.stories.published.size,
        # drafts: user.stories.draft.size,
        # media_uploads: user.media_uploads_count,
        # campaign: user.lpage,
        # invitations: Invitation.joins(:sender).where(sender: user).size
      }
    }
  end

  private

  def user
    @user ||= current_user
  end
end
