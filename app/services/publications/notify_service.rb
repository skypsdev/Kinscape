module Publications
  class NotifyService < ApplicationService
    def initialize(publication, current_user)
      @publication = publication
      @current_user = current_user
    end

    def call
      return unless publication.persisted?
      return if publication.publish_on

      publication.update(notified_at: Time.zone.now)
      ::MailerService.call(
        :story_published,
        params: {
          publisher: current_user,
          recipients_mails: recipients_mails,
          publication: publication
        }
      )
    end

    private

    attr_reader :publication, :current_user

    def recipients_mails
      recipients = publication.family.users - [current_user]
      recipients.pluck(:email)
    end
  end
end
