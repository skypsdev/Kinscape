class MailerPreview < ActionMailer::Preview
  def invitation
    Mailer.invitation(invitation: Invitation.last)
  end

  def existing_user_invitation
    # recipient must be present in invitation
    Mailer.existing_user_invitation(invitation: Invitation.last)
  end

  def email_confirmation
    recipient = User.new first_name: 'Jake',
                         last_name: 'Smith',
                         email: 'jake.smith@example.com',
                         confirmation_token: 'token'

    Mailer.email_confirmation recipient: recipient
  end

  def story_published
    publisher = User.first
    recipient = User.last

    Mailer.story_published(
      publisher: publisher,
      recipient: recipient,
      story: Story.first,
      family: publisher.families.first
    )
  end

  def story_updated
    Mailer.story_updated(
      publisher: User.first,
      recipient: User.last,
      story: Story.first,
      family: publisher.families.first
    )
  end

  def time_capsule_released
    publisher = User.first
    recipient = User.last
    story = Story.first
    time_capsule = story.publications.build publish_on: 2.days.from_now

    Mailer.time_capsule_released(
      publisher: publisher,
      recipient: recipient,
      time_capsule: time_capsule
    )
  end

  def story_images
    recipient = User.last
    story = recipient.stories.last

    Mailer.story_images(
      recipient: recipient,
      story: story,
      file_url: 'https://www.example.com/download.zip'
    )
  end

  def transfer_confirmation
    Mailer.transfer_confirmation(ownership_transfer: OwnershipTransfer.last)
  end

  def trial_will_end
    Mailer.trial_will_end(recipient: User.first)
  end
end
