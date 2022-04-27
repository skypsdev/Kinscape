class MailerPreview < ActionMailer::Preview
  # run rails db:seed before using previews

  def role_change
    Mailer.role_change(kinship: Kinship.default_access.first)
  end

  def admin_transfer
    Mailer.admin_transfer(ownership_transfer: ownership)
  end

  def admin_transfer_accepted
    Mailer.admin_transfer_accepted(ownership_transfer: ownership)
  end

  def admin_transfer_rejected
    Mailer.admin_transfer_rejected(ownership_transfer: ownership)
  end

  def community_story_deleted
    Mailer.community_story_deleted(publication: Publication.community_type.first, user: User.first)
  end

  def shared_story_deleted
    Mailer.shared_story_deleted(publication: Publication.shared_type.first, user: User.first)
  end

  def removed_from_community
    Mailer.removed_from_community(kinship: Kinship.default_access.first, user: User.first)
  end

  def community_deleted
    Mailer.community_deleted(family: Family.default_access.first, user: User.first)
  end

  def change_active_to_offline_member
    Mailer.change_active_to_offline_member(kinship: Kinship.default_access.first, user: User.first)
  end

  def invitation_family_no_account
    invitation = Invitation.joins(:family).find_by(recipient_id: nil, families: { access_type: :default })
    invitation ||= Invitation.create!(
      email: 'siema@z.rana',
      sender: User.first,
      family: Family.default_access.first,
      message: "Some message from invitation. \n with a new line!! \n \n and some space between"
    )
    Mailer.invitation(invitation: invitation)
  end

  def invitation_family_account
    invitation = Invitation.joins(:family).where.not(recipient_id: nil).find_by(families: { access_type: :default })
    invitation ||= Invitation.create!(
      email: 'siema1@z.rana',
      sender: User.first,
      family: Family.default_access.first,
      recipient: User.last,
      message: "Some message from invitation. \n with a new line!! \n \n and some space between"
    )
    Mailer.invitation(invitation: invitation)
  end

  def invitation_my_people_account
    invitation = Invitation.joins(:family).where.not(recipient_id: nil).find_by(families: { access_type: :personal })
    invitation ||= Invitation.create!(
      email: 'siema2@z.rana',
      sender: User.first,
      family: User.first.personal_family,
      recipient: User.last,
      message: "Some message from invitation. \n with a new line!! \n \n and some space between"
    )
    Mailer.invitation(invitation: invitation)
  end

  def invitation_my_people_no_account
    invitation = Invitation.joins(:family).find_by(recipient_id: nil, families: { access_type: :personal })
    invitation ||= Invitation.create!(
      email: 'siema3@z.rana',
      sender: User.first,
      family: User.first.personal_family,
      message: "Some message from invitation. \n with a new line!! \n \n and some space between"
    )
    Mailer.invitation(invitation: invitation)
  end

  def invitation_offline_account
    offline_member = Family.default_access.first.offline_members.first
    offline_member ||= Family.default_access.first.offline_members.create!(nickname: 'offline name')
    invitation = Invitation.joins(:kinship).where.not(recipient_id: nil).find_by(kinships: { role: :offline_member })
    invitation ||= Invitation.create(
      email: 'siema45@z.rana',
      sender: User.first,
      family: Family.default_access.first,
      recipient: User.last,
      kinship: offline_member,
      message: "Some message from invitation. \n with a new line!! \n \n and some space between"
    )
    Mailer.invitation(invitation: invitation)
  end

  def invitation_offline_no_account
    offline_member = Family.default_access.first.offline_members.first
    offline_member ||= Family.default_access.first.offline_members.create!(nickname: 'offline name')
    invitation = Invitation.joins(:kinship).find_by(recipient_id: nil, kinships: { role: :offline_member })
    invitation ||= Invitation.create!(
      email: 'siema5@z.rana',
      sender: User.first,
      family: Family.default_access.first,
      kinship: offline_member,
      message: "Some message from invitation. \n with a new line!! \n \n and some space between"
    )
    Mailer.invitation(invitation: invitation)
  end

  private

  def ownership
    OwnershipTransfer.first || OwnershipTransfer.create(
      family: admin_kinship.family,
      new_admin: admin_kinship.family.kinships.where.not(id: admin_kinship.id).first.user,
      old_admin: admin_kinship.user,
      expires_at: Time.current.tomorrow
    )
  end

  def admin_kinship
    @admin_kinship ||= Family.default_access.first.admin_kinship
  end
end
