IntercomRails.config do |config|
  config.app_id = ENV['INTERCOM_APP_ID'] || Global.intercom.app_id

  config.api_secret = ENV['INTERCOM_API_SECRET']

  config.enabled_environments = []

  config.user.current = proc { env[:clearance].current_user }

  media_uploads_proc = proc do |user|
    user
      .stories
      .map { |story| story.sections.map(&:media_type) }
      .flatten.reject { |type| type == 'text' }.count
  end

  invitations_proc = proc do |user|
    Invitation.joins(:sender).where(sender: user).count
  end

  config.user.custom_data = {
    campaign: proc { |user| user.lpage },
    drafts: proc { |user| user.stories.draft.count },
    families: proc { |user| user.families.count },
    invitations: invitations_proc,
    media_uploads: media_uploads_proc,
    stories: proc { |user| user.stories.published.count }
  }

  config.company.current = proc { |user| user.families.first }

  config.company.custom_data = {
    total_invitations: proc { |app| app.invitations.count },
    total_stories: proc { |app| app.stories.count },
    total_members: proc { |app| app.users.count }
  }

  config.inbox.style = :custom
  config.hide_default_launcher = true
end
