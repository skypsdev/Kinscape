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
      'Email Confirmation',
      'RECIPIENT_NAME' => recipient.first_name,
      'CONFIRMATION_URL' => confirm_email_url(params),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def reset_password(recipient:)
    subject = t('passwords.new.title')
    body = mandrill_template(
      'reset-password',
      'RECIPIENT_NAME' => recipient.name,
      'RESET_URL' => edit_user_password_url(recipient, token: recipient.confirmation_token),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: recipient.email, subject: subject, body: body)
  end

  def invitation(invitation:)
    subject = t('invitations.subject', sender: invitation.sender_name, family: invitation.family_name)
    body = mandrill_template(
      'new-user-invitation',
      'SENDER_NAME' => invitation.sender_name,
      'FAMILY_NAME' => invitation.family_name,
      'MESSAGE' => invitation.message.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'JOIN_URL' => invitation_url(invitation.id),
      'DECLINE_URL' => decline_invitation_url(invitation.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: invitation.email, subject: subject, body: body)
  end

  def existing_user_invitation(invitation:)
    subject = t('invitations.subject', sender: invitation.sender_name, family: invitation.family_name)
    body = mandrill_template(
      'existing-user-invitation',
      'SENDER_NAME' => invitation.sender_name,
      'RECIPIENT_NAME' => invitation.recipient.name,
      'RECIPIENT_EMAIL' => invitation.email,
      'FAMILY_NAME' => invitation.family_name,
      'MESSAGE' => invitation.message.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'FAMILY_URL' => invitation_url(invitation.id),
      'DECLINE_URL' => decline_invitation_url(invitation.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: invitation.email, subject: subject, body: body)
  end

  def sender_message_send(sender:, message:, family:, recipient:, receiver:)
    subject = t('.subject', user_name: sender.name)
    body = mandrill_template(
      'sender-message-send',
      'RECIPIENT_NAME' => sender.name,
      'MESSAGE' => message.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'FAMILY' => family.name,
      'CURRENT_YEAR' => Time.current.year,
      'RECEIVER_NAME' => receiver
    )
    send_mail(to: recipient, subject: subject, body: body, reply_to: "#{sender.name} <#{sender.email}>")
  end

  def send_message(sender:, message:, family:, recipients:, recipients_name:)
    subject = t('.subject', user_name: sender.name)
    body = mandrill_template(
      'send-message',
      'REQUESTER_NAME' => sender.name,
      'MESSAGE' => message.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'FAMILY' => family.name,
      'CURRENT_YEAR' => Time.current.year,
      'URL' => mylife_profile_url(reply: true),
      'RECIPIENT_NAME' => recipients_name
    )
    send_mail(to: recipients, subject: subject, body: body, reply_to: "#{sender.name} <#{sender.email}>")
  end

  def story_published(publisher:, recipients_mails:, publication:)
    subject = t('.subject', user_name: publisher.name)
    body = mandrill_template(
      'story-published',
      'PUBLISHER_NAME' => publisher.name,
      'FAMILY_NAME' => publication.family.name,
      'STORY_TITLE' => publication.story.title,
      'STORY_URL' => story_url(publication.id),
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
    subject = t('.subject', user_name: publisher.name, story_title: publication.story.title)
    body = mandrill_template(
      'story-updated',
      'PUBLISHER_NAME' => publisher.name,
      'RECIPIENT_NAME' => recipient.name,
      'FAMILY_NAME' => publication.family.name,
      'STORY_TITLE' => publication.story.title,
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

  def comment_created(recipient:, comment:, publication:)
    item_name = comment.commentable_type.downcase
    subject = t('.subject', user_name: comment.user.name, item: item_name)
    body = mandrill_template(
      'comment-created',
      'COMMENTER_NAME' => comment.user.name,
      'RECIPIENT_NAME' => recipient.name,
      'ITEM_NAME' => item_name,
      'MESSAGE' => comment.body.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'FAMILY_NAME' => publication.family.name,
      'STORY_URL' => story_url(publication.id),
      'STORY_TITLE' => publication.story.title,
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

  def transfer_confirmation(ownership_transfer:)
    subject = t('transfer.email.subject', sender: ownership_transfer.old_admin.name)
    kinship = ownership_transfer.family.kinship_for(ownership_transfer.new_admin)
    body = mandrill_template(
      'transfer-confirmation',
      'SENDER_NAME' => ownership_transfer.old_admin.name,
      'RECIPIENT_NAME' => ownership_transfer.new_admin.name,
      'FAMILIES_LIST' => t('families.name', family_name: ownership_transfer.family.name),
      'MESSAGE_URL' => kinship_mylife_profile_url(kinship, reply: true),
      'CONFIRMATION_URL' => families_ownership_transfer_url(ownership_transfer.id),
      'END_DATE' => ownership_transfer.expires_at,
      'CURRENT_YEAR' => Time.zone.today.year
    )

    send_mail(to: ownership_transfer.new_admin.email, subject: subject, body: body)
  end

  def active_member_to_offline(family:, user:)
    subject = t('.subject')
    body = mandrill_template(
      'active-member-to-offline',
      'ADMIN_NAME' => family.admin.name,
      'COMMUNITY_NAME' => family.name,
      'CURRENT_YEAR' => Time.zone.today.year,
      'URL' => root_url # TODO-OFFLINE-MEMBER: change it!
    )

    send_mail(to: user.email, subject: subject, body: body)
  end

  def offline_member_to_active(invitation:)
    subject = t('.subject')
    body = mandrill_template(
      'offline-member-to-active',
      'ADMIN_NAME' => invitation.family.admin.name,
      'COMMUNITY_NAME' => invitation.family.name,
      'COMMUNITY_TYPE' => invitation.family.family_type,
      'MESSAGE' => invitation.message.gsub(/(?:\n\r?|\r\n?)/, '<br>'),
      'CURRENT_YEAR' => Time.zone.today.year,
      'ACCEPT_URL' => invitation_url(invitation.id),
      'DECLINE_URL' => decline_invitation_url(invitation.id)
    )

    send_mail(to: invitation.email, subject: subject, body: body)
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
    subject = "Kinscape: #{user.name} appreciated your story 😀"
    body = mandrill_template(
      'appreciation',
      'RECIPIENT_NAME' => publication.story.user.name,
      'APPRECIATOR_NAME' => user.name,
      'STORY_TITLE' => publication.story.title,
      'STORY_URL' => story_url(publication.id),
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: publication.story.user.email, subject: subject, body: body)
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

  def notify_previous_admin(ownership_transfer:)
    subject = t(".#{ownership_transfer.status}.subject")
    body = mandrill_template(
      'notify-previous-connector',
      'RECEIVER_NAME' => ownership_transfer.old_admin.name,
      'CONNECTOR_NAME' => ownership_transfer.new_admin.name,
      'FAMILY_NAME' => ownership_transfer.family.name,
      'CURRENT_YEAR' => Time.current.year,
      'STATUS' => ownership_transfer.status_accepted?
    )

    send_mail(to: ownership_transfer.old_admin.email, subject: subject, body: body)
  end

  def decline_family_invitation(user:, family:, admin:)
    subject = t('.subject', user_name: user.name, family_name: family.name)
    body = mandrill_template(
      'decline-family-invitation',
      'MEMBER_NAME' => user.name,
      'RECIPIENT_NAME' => admin.name,
      'RECIPIENT_EMAIL' => admin.email,
      'FAMILY_NAME' => family.name,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: admin.email, subject: subject, body: body)
  end

  def welcome_to_family(user:, family:)
    subject = t('.subject', family_name: family.name)
    body = mandrill_template(
      'welcome-to-family',
      'MEMBER_NAME' => user.name,
      'FAMILY_NAME' => family.name,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: user.email, subject: subject, body: body)
  end

  def welcome_to_kinscape(user:)
    subject = t('.subject')
    body = mandrill_template(
      'welcome-to-kinscape-new-member',
      'RECIPIENT_NAME' => user.name,
      'CURRENT_YEAR' => Time.current.year
    )

    send_mail(to: user.email, subject: subject, body: body)
  end

  def user_joined_family(recipients:, new_member:, family:, recipients_name:)
    subject = t('.subject')
    template = if new_member.instance_of?(User)
                 'user-joined-family-using-invitation'
               elsif new_member.instance_of?(Kinship)
                 'user-joined-family'
               end

    body = mandrill_template(
      template,
      'NEW_USER_NAME' => new_member.name,
      'FAMILY_NAME' => family.name,
      'CURRENT_YEAR' => Time.current.year,
      'URL' => family_url(family.uid),
      'RECIPIENT_NAME' => recipients_name
    )

    send_mail(to: recipients, subject: subject, body: body)
  end

  private

  def send_mail(params)
    params[:subject] += ' (Staging)' if Rails.env.staging?
    params = reject_fake_emails(params)
    return unless params[:to]

    mail(**params)
  end

  def reject_fake_emails(params)
    case params[:to]
    when String
      params[:to] = nil if params[:to].include?('@fake.kinscape.com')
    when Array
      params[:to] = params[:to].filter_map do |email|
        next if email.include?('@fake.kinscape.com')

        email
      end
    end
    params
  end

  def mandrill_template(template_name, attributes)
    mandrill = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])
    merge_vars = attributes.map { |key, value| { name: key, content: value } }
    mandrill.templates.render(template_name: template_name, template_content: {}, merge_vars: merge_vars)['html']
  end
end

# rubocop:enable Metrics/ClassLength
