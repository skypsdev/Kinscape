# rubocop:disable Metrics/ClassLength

require 'MailchimpTransactional'

class Mailer < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  include VueRoutesHelper

  default(
    from: Clearance.configuration.mailer_sender,
    reply_to: Clearance.configuration.mailer_sender,
    content_type: 'text/html'
  )

  def email_confirmation(recipient:, invitation_id:)
    subject = t('email_confirmation.title')
    params = { token: recipient.confirmation_token, invitation_id: invitation_id }.compact
    body = mandrill_template(
      'email-confirmation-new',
      'CONFIRMATION_URL' => confirm_email_url(params),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def reset_password(recipient:)
    subject = t('passwords.new.title')
    body = mandrill_template(
      'Request Password Reset',
      'RESET_URL' => edit_user_password_url(recipient, token: recipient.confirmation_token),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def sender_message_send(subject:, message:, family:, recipient:, receiver:)
    subj = t('.subject')
    body = mandrill_template(
      'sender-message-send-new',
      'RECEIVER_NAME' => receiver,
      'SUBJECT' => subject,
      'MESSAGE' => message.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'FAMILY' => family.name,
      'CURRENT_YEAR' => Time.current.year
    )
    send_mail(to: recipient, subject: subj, body: body)
  end

  def send_message(sender:, subject:, message:, family:, recipients:)
    kinship = Kinship.find_by(user_id: sender.id, family_id: family.id)
    subj = t('.subject', user_name: kinship.nickname)
    body = mandrill_template(
      'send-message-new',
      'REQUESTER_NAME' => kinship.nickname,
      'SUBJECT' => subject,
      'MESSAGE' => message.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'FAMILY' => family.name,
      'CURRENT_YEAR' => Time.current.year,
      'URL' => "#{root_url}communities/members/#{kinship.id}"
    )
    send_mail(to: recipients, subject: subj, body: body, reply_to: "#{kinship.nickname} <#{sender.email}>")
  end

  def story_published(publisher:, recipients_mails:, publication:)
    subject = t('mailer.story_published.community_story')
    message = t('mailer.story_published.community_story_messsage',
                publisher_name: publisher.name,
                family_name: publication.family.name,
                story_title: publication.story.title)
    if publication.family.personal_access?
      subject = t('mailer.story_published.lify_story')
      message = t('mailer.story_published.lify_story_message',
                  publisher_name: publisher.name,
                  story_title: publication.story.title)
    end
    body = mandrill_template(
      'story-shared',
      'MESSAGE' => message,
      'STORY_URL' => story_url(publication.id),
      'COVER_IMAGE_URL' => image_link(publication.story.cover_url),
      'CURRENT_YEAR' => Time.current.year
    )
    recipients_mails.each do |mail|
      send_mail(
        to: mail,
        subject: subject,
        body: body,
        from: "#{publisher.name} <no-reply@kinscape.com>",
        reply_to: "#{publisher.name} <#{publisher.email}>"
      )
    end
  end

  def time_capsule_released(publisher:, recipient:, time_capsule:)
    subject = t('.subject', user_name: publisher.name)
    body = mandrill_template(
      'time-capsule-released',
      'PUBLISHER_NAME' => publisher.name,
      'RECIPIENT_NAME' => recipient.name,
      'FAMILY_NAME' => time_capsule.family.name,
      'STORY_TITLE' => time_capsule.story.title,
      'PUBLISH_DATE' => time_capsule.publish_on,
      'STORY_URL' => story_url(time_capsule.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{publisher.name} <no-reply@kinscape.com>",
      reply_to: "#{publisher.name} <#{publisher.email}>"
    )
  end

  def story_updated(publisher:, recipient:, publication:)
    subject = t('.subject')
    body = mandrill_template(
      'story-updated-generic',
      'PUBLISHER_NAME' => publisher.name,
      'RECIPIENT_NAME' => recipient.name,
      'FAMILY_NAME' => publication.family.name,
      'STORY_TITLE' => publication.story.title,
      'COVER_IMAGE_URL' => image_link(publication.story.cover_url),
      'STORY_URL' => story_url(publication.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{publisher.name} <no-reply@kinscape.com>",
      reply_to: "#{publisher.name} <#{publisher.email}>"
    )
  end

  def story_updated_chapter_added(publisher:, recipient:, publication:, section:)
    subject = t('.subject')
    body = mandrill_template(
      'story-updated-chapter-added',
      'PUBLISHER_NAME' => publisher.name,
      'FAMILY_NAME' => publication.family.name,
      'STORY_TITLE' => section.story.title,
      'CHAPTER_TITLE' => section.title,
      'COVER_IMAGE_URL' => image_link(publication.story.cover_url),
      'STORY_URL' => story_url(publication.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{publisher.name} <no-reply@kinscape.com>",
      reply_to: "#{publisher.name} <#{publisher.email}>"
    )
  end

  def member_profile_updated_generic(publisher:, recipient:)
    subject = t('.subject')
    body = mandrill_template(
      'member-profile-updated-generic',
      'NICKNAME' => publisher.name,
      'FAMILY_NAME' => publisher.family.name,
      'MEMBER_IMAGE_URL' => image_link(publisher.avatar_url),
      'PROFILE_URL' => "#{root_url}communities/members/#{publisher.id}",
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{publisher.name} <no-reply@kinscape.com>",
      reply_to: "#{publisher.name} <#{publisher.email}>"
    )
  end

  def member_profile_updated_chapter(publisher:, recipient:, chapter:)
    subject = t('.subject')
    body = mandrill_template(
      'member-profile-updated-chapter',
      'NICKNAME' => publisher.name,
      'CHAPTER_TITLE' => chapter.title,
      'FAMILY_NAME' => publisher.family.name,
      'MEMBER_IMAGE_URL' => image_link(publisher.avatar_url),
      'PROFILE_URL' => "#{root_url}communities/members/#{publisher.id}",
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{publisher.name} <no-reply@kinscape.com>",
      reply_to: "#{publisher.name} <#{publisher.email}>"
    )
  end

  def personal_profile_updated_generic(publisher:, recipient:)
    subject = t('.subject')
    body = mandrill_template(
      'personal-profile-updated-generic',
      'NICKNAME' => publisher.name,
      'MEMBER_IMAGE_URL' => image_link(publisher.avatar_url),
      'PROFILE_URL' => "#{root_url}communities/members/#{publisher.id}",
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{publisher.name} <no-reply@kinscape.com>",
      reply_to: "#{publisher.name} <#{publisher.email}>"
    )
  end

  def personal_profile_updated_chapter(publisher:, recipient:, chapter:)
    subject = t('.subject')
    body = mandrill_template(
      'personal-profile-updated-chapter',
      'NICKNAME' => publisher.name,
      'CHAPTER_TITLE' => chapter.title,
      'MEMBER_IMAGE_URL' => image_link(publisher.avatar_url),
      'PROFILE_URL' => "#{root_url}communities/members/#{publisher.id}",
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{publisher.name} <no-reply@kinscape.com>",
      reply_to: "#{publisher.name} <#{publisher.email}>"
    )
  end

  def offline_member_profile_updated_generic(admin:, recipient:, member:)
    subject = t('.subject')
    body = mandrill_template(
      'offline-member-profile-updated-generic',
      'ADMIN_NAME' => admin.name,
      'NICKNAME' => member.name,
      'COMMUNITY_NAME' => member.family.name,
      'MEMBER_IMAGE_URL' => image_link(member.avatar_url),
      'PROFILE_URL' => "#{root_url}communities/members/#{member.id}",
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{admin.name} <no-reply@kinscape.com>",
      reply_to: "#{admin.name} <#{admin.email}>"
    )
  end

  def offline_member_profile_updated_chapter(admin:, recipient:, member:, chapter:)
    subject = t('.subject')
    body = mandrill_template(
      'offline-member-profile-updated-chapter',
      'ADMIN_NAME' => admin.name,
      'NICKNAME' => member.name,
      'COMMUNITY_NAME' => member.family.name,
      'CHAPTER_TITLE' => chapter.title,
      'MEMBER_IMAGE_URL' => image_link(member.avatar_url),
      'PROFILE_URL' => "#{root_url}communities/members/#{member.id}",
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: recipient.email,
      subject: subject,
      body: body,
      from: "#{admin.name} <no-reply@kinscape.com>",
      reply_to: "#{admin.name} <#{admin.email}>"
    )
  end

  def story_images(recipient:, story:, file_url:)
    subject = t('.subject', story_title: story.title)
    body = mandrill_template(
      'story-asset-download',
      'REQUESTER_NAME' => recipient.name,
      'STORY_TITLE' => story.title,
      'URL' => file_url,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def comment_created(recipient:, comment:, publication:, commentable:)
    subject = t('.story_comment')
    message = t('.story_message',
                commenter_name: comment.user.name,
                story_title: publication.story.title)
    if commentable.instance_of?(Section)
      subject = t('.chapter_comment')
      message = t('.chapter_message',
                  commenter_name: comment.user.name,
                  story_title: publication.story.title,
                  chapter_title: commentable.title)
    end
    avatar_url = publication&.family&.kinships&.find_by(user_id: recipient.id)&.avatar_url
    body = mandrill_template(
      'comment',
      'MESSAGE' => message,
      'STORY_URL' => story_url(publication.id),
      'MEMBER_PROFILE_IMAGE' => image_link(avatar_url),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def trial_will_end(recipient:)
    subject = t('.subject')
    body = mandrill_template(
      'trial-will-end',
      'RECIPIENT_NAME' => recipient.name,
      'PAYMENT_METHOD_URL' => new_billing_card_url,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def kpi_weekly
    subject = "#{Time.zone.today.strftime('%F')} KPIs for week \##{Time.zone.today.cweek}"
    @weekly_data = KpiService.gather_kpis
    rendered_kpis = render_to_string 'kpi_weekly'

    kpis = {
      'TABLE' => rendered_kpis,
      'CURRENT_YEAR' => Time.zone.today.year
    }

    body = mandrill_template('kpi-weekly', kpis)

    recipients = User.where(admin: true).pluck(:email)
    send_mail(bcc: recipients, subject: subject, body: body)
  end

  def storage_limit(sender:, recipient:)
    subject = t('.subject', user_name: sender.name)
    body = mandrill_template(
      'member-storage-limit-hit',
      'USER_NAME' => sender.name,
      'USER_ID' => sender.id,
      'FAMILY' => sender.owned_families.first&.name, # TODO: first is not the best choice
      'RECIPIENT_NAME' => recipient.name,
      'STORAGE_SIZE' => 'mocked size Kb',
      'STORAGE_LIMIT' => "#{ENV['USER_STORAGE_LIMIT_WARNING']} GB",
      'CURRENT_YEAR' => Time.zone.today.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def appreciate_on_story(user:, publication:)
    subject = t('.subject')
    body = mandrill_template(
      'appreciation-story',
      'APPRECIATOR_NAME' => user.name,
      'STORY_TITLE' => publication.story.title,
      'STORY_URL' => story_url(publication.id),
      'COVER_IMAGE_URL' => image_link(publication.story.cover_url),
      'NUM_OTHERS' => publication.appreciations_count - 1,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: publication.story.user.email, subject: subject, body: body)
  end

  def appreciate_on_chapter(publication_id:, section:)
    subject = t('.subject')
    body = mandrill_template(
      'appreciation-chapter',
      'APPRECIATORS_COUNT' => section.appreciations_count,
      'STORY_TITLE' => section.story.title,
      'CHAPTER_TITLE' => section.title,
      'STORY_URL' => story_url(publication_id),
      'COVER_IMAGE_URL' => image_link(section.story.cover_url),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: section.story.user.email, subject: subject, body: body)
  end

  def appreciate_on_profile_chapter(kinship:, chapter:)
    subject = t('.subject')
    body = mandrill_template(
      'appreciation-profile-chapter',
      'APPRECIATOR_COUNT' => chapter.appreciations_count,
      'FAMILY_NAME' => kinship.family.name,
      'CHAPTER_TITLE' => chapter.title,
      'CHAPTER_URL' => "#{root_url}communities/members/#{kinship.id}",
      'COVER_IMAGE_URL' => image_link(kinship.avatar_url),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: kinship.user.email, subject: subject, body: body)
  end

  def plan_ending(recipient:, end_sub_days:, end_sub_msg:)
    subject = end_sub_days
    body = mandrill_template(
      'Plan Ending',
      'RECIPIENT_NAME' => recipient.name,
      'END_SUB_DAYS' => end_sub_days,
      'END_SUB_MSG' => end_sub_msg,
      'CURRENT_YEAR' => Time.current.year,
      'PAYMENT_METHOD_URL' => new_billing_card_url
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def thank_you_for_subscribe(recipient:)
    subject = t('.subject')
    body = mandrill_template(
      'Thank You for Subscribing',
      'RECIPIENT_NAME' => recipient.name,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def paid_for_subscription(subscriber:, recipient:, family_names:)
    template = if subscriber.subscription&.individual_plan?
                 'individual-payment-notification'
               elsif subscriber.subscription&.group_plan?
                 'group-payment-notification'
               end
    subject = t('.subject')
    body = mandrill_template(
      template,
      'RECIPIENT_NAME' => recipient.name,
      'SUBSCRIBER_NAME' => subscriber.name,
      'FAMILY_NAMES' => family_names,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def email_password_to_user(kinship:, password:)
    subject = t('.subject')
    body = mandrill_template(
      'email-password-to-user',
      'USER_NAME' => kinship.user.name,
      'USER_PASSWORD' => password,
      'FAMILY_NAME' => kinship.family.name,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: kinship.user.email, subject: subject, body: body)
  end

  def decline_family_invitation(user:, family:, admin:)
    subject = t('.subject')
    body = mandrill_template(
      'Invitation Rejection',
      'MEMBER_NAME' => user.name,
      'RECIPIENT_NAME' => admin.name,
      'FAMILY_NAME' => family.name,
      'FAMILY_TYPE' => family.family_type,
      'COVER_IMAGE_URL' => image_link(family.cover_image_url),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: admin.email, subject: subject, body: body)
  end

  def user_joined_family(recipients:, new_member:, family:)
    subject = t('.subject')
    subject = "#{subject} Profile" if new_member.instance_of?(Kinship)
    template = if new_member.instance_of?(User)
                 'user-joined-family-using-invitation'
               elsif new_member.instance_of?(Kinship)
                 'user-joined-family'
               end
    avatar_url = family.kinships.find_by(user_id: new_member.id)&.avatar_url
    body = mandrill_template(
      template,
      'NEW_USER_NAME' => new_member.name,
      'FAMILY_NAME' => family.name,
      'FAMILY_TYPE' => family.family_type,
      'CURRENT_YEAR' => Time.current.year,
      'URL' => "#{root_url}communities/members/#{new_member.id}",
      'ADMIN_NAME' => family.admin.name,
      'PROFILE_IMAGE_URL' => image_link(avatar_url)
    )

    send_mail(to: recipients, subject: subject, body: body)
  end

  #### NEW CONTENT

  def role_change(kinship:)
    family = kinship.family
    subject = t('mailer.role_change.subject', family_name: family.name)
    body = mandrill_template(
      'role-change',
      'ADMIN_NAME' => family.admin.name,
      'ROLE' => kinship.role.humanize,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_IMAGE_URL' => image_link(family.cover_image_url),
      'COMMUNITY_URL' => family_url(family.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: kinship.user.email, subject: subject, body: body)
  end

  def admin_transfer(ownership_transfer:)
    family = ownership_transfer.family
    subject = t('mailer.admin_transfer.subject')
    body = mandrill_template(
      'admin-transfer',
      'ADMIN_NAME' => family.admin.name,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TYPE' => family.family_type,
      'COMMUNITY_IMAGE_URL' => image_link(family.cover_image_url),
      'OWNERSHIP_URL' => families_ownership_transfer_url(ownership_transfer.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: ownership_transfer.new_admin.email,
      subject: subject,
      body: body,
      'Importance' => 'high',
      'X-Priority' => '1'
    )
  end

  def admin_transfer_accepted(ownership_transfer:)
    family = ownership_transfer.family
    subject = t('mailer.admin_transfer_accepted.subject')
    body = mandrill_template(
      'admin-transfer-accepted',
      'NEW_ADMIN_NAME' => ownership_transfer.new_admin.name,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TYPE' => family.family_type,
      'COMMUNITY_IMAGE_URL' => image_link(family.cover_image_url),
      'COMMUNITY_URL' => family_url(family.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: ownership_transfer.old_admin.email,
      subject: subject,
      body: body,
      'Importance' => 'high',
      'X-Priority' => '1'
    )
  end

  def admin_transfer_rejected(ownership_transfer:)
    family = ownership_transfer.family
    subject = t('mailer.admin_transfer_rejected.subject')
    body = mandrill_template(
      'admin-transfer-rejected',
      'NEW_ADMIN_NAME' => ownership_transfer.new_admin.name,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TYPE' => family.family_type,
      'COMMUNITY_IMAGE_URL' => image_link(family.cover_image_url),
      'COMMUNITY_URL' => family_url(family.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(
      to: ownership_transfer.old_admin.email,
      subject: subject,
      body: body,
      'Importance' => 'high',
      'X-Priority' => '1'
    )
  end

  def community_story_deleted(publication:, user:)
    family = publication.family
    subject = t('mailer.community_story_deleted.subject')
    body = mandrill_template(
      'community-story-deleted',
      'ADMIN_NAME' => family.kinships.find_by(user_id: user.id).nickname,
      'COMMUNITY_NAME' => family.name,
      'STORY_TITLE' => publication.story.title,
      'CURRENT_YEAR' => Time.current.year
    )
    recipients = publication.family.users.pluck(:email)
    send_mail(to: recipients, subject: subject, body: body)
  end

  def shared_story_deleted(publication:, user:)
    family = publication.family
    subject = t('mailer.shared_story_deleted.subject')
    body = mandrill_template(
      'shared-story-deleted',
      'ADMIN_NAME' => family.kinships.find_by(user_id: user.id).nickname,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TITLE' => family.family_type,
      'STORY_TITLE' => publication.story.title,
      'CURRENT_YEAR' => Time.current.year,
      'OWNER_MESSAGE' => ''
    )
    recipients = publication.family.users.where.not(id: publication.story.user_id).pluck(:email)
    send_mail(to: recipients, subject: subject, body: body)
  end

  def shared_story_deleted_owner(publication:, user:)
    family = publication.family
    subject = t('mailer.shared_story_deleted.subject')
    body = mandrill_template(
      'shared-story-deleted',
      'ADMIN_NAME' => family.kinships.find_by(user_id: user.id).nickname,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TITLE' => family.family_type,
      'STORY_TITLE' => publication.story.title,
      'CURRENT_YEAR' => Time.current.year,
      'OWNER_MESSAGE' => 'You still have your own copy in My Life.'
    )
    send_mail(to: publication.story.user.email, subject: subject, body: body)
  end

  def removed_from_community(kinship:, user:)
    family = kinship.family
    subject = t('mailer.removed_from_community.subject')
    body = mandrill_template(
      'removed-from-community',
      'ADMIN_NAME' => family.kinships.find_by(user_id: user.id).nickname,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TITLE' => family.family_type,
      'COMMUNITY_IMAGE_URL' => image_link(family.cover_image_url),
      'CURRENT_YEAR' => Time.current.year
    )
    send_mail(to: kinship.user.email, subject: subject, body: body)
  end

  def community_deleted(family:, user:)
    subject = t('mailer.community_deleted.subject', family_name: family.name)
    body = mandrill_template(
      'community-deleted',
      'ADMIN_NAME' => family.kinships.find_by(user_id: user.id).nickname,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TITLE' => family.family_type,
      'CURRENT_YEAR' => Time.current.year
    )
    recipients = family.users.pluck(:email)
    send_mail(to: recipients, subject: subject, body: body)
  end

  def change_active_to_offline_member(kinship:, user:)
    family = kinship.family
    subject = t('mailer.change_active_to_offline_member.subject', user_name: kinship.nickname)
    body = mandrill_template(
      'change-active-to-offline-member',
      'ADMIN_NAME' => family.kinships.find_by(user_id: user.id).nickname,
      'MEMBER_NAME' => kinship.nickname,
      'COMMUNITY_NAME' => family.name,
      'COMMUNITY_TITLE' => family.family_type,
      'COMMUNITY_IMAGE_URL' => image_link(family.cover_image_url),
      'CURRENT_YEAR' => Time.current.year
    )
    send_mail(to: kinship.user.email, subject: subject, body: body)
  end

  def invitation(invitation:)
    type, cover_image_url =
      if invitation.kinship&.role_offline_member?
        [:offline, invitation.family.cover_image_url]
      elsif invitation.family.personal_access?
        [:my_people, invitation.sender.personal_kinship.avatar_url]
      else
        [:family, invitation.family.cover_image_url]
      end
    account, template, accept_url =
      if invitation.recipient
        [:with_account, 'community-invite', invitation_url(invitation.id)]
      else
        [:without_account, 'community-invite-no-account',
         sign_up_url(invitation_id: invitation.id)]
      end
    sender_name = invitation.family.kinship_for(invitation.sender).nickname
    subject = t("mailer.invitation.#{account}.subject", user: sender_name)
    pre_message = t("mailer.invitation.#{account}.#{type}.pre_message",
                    sender: sender_name,
                    community_name: invitation.family_name,
                    community_type: invitation.family.family_type)
    body = mandrill_template(
      template,
      'PRE_MESSAGE' => pre_message,
      'COVER_IMAGE_URL' => image_link(cover_image_url),
      'MESSAGE' => invitation.message.gsub(/\n\r?|\r\n?/, '<br>'),
      'ACCEPT_URL' => accept_url,
      'TOUR_URL' => "#{root_url}join",
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: invitation.email, subject: subject, body: body)
  end

  private

  def send_mail(params)
    params[:subject] += ' (Staging)' if Rails.env.staging?
    return unless params[:to]

    mail(**params)
  end

  def mandrill_template(template_name, attributes)
    if Rails.env.development? && ENV['MANDRILL_API_KEY'].blank?
      return 'ask someone for MANDRILL_API_KEY to display mails content'
    end

    mandrill = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])
    merge_vars = attributes.map { |key, value| { name: key, content: value } }
    mandrill.templates.render(template_name: template_name, template_content: {}, merge_vars: merge_vars)['html']
  end

  def image_link(url)
    return "#{root_url}#{url}" if url

    ActionController::Base.helpers.image_url('small-logo.png')
  end
end

# rubocop:enable Metrics/ClassLength
