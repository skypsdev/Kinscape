module Stories
  class NotificationService
    class << self
      def notify_contribution(publication, user)
        publication.update(notified_at: Time.zone.now)
        recipients = publication.family.users.where.not(id: user.id)
        recipients.each do |recipient|
          ::MailerService.call(
            :story_updated,
            params: {
              publisher: user,
              recipient: recipient,
              publication: publication
            }
          )
        end
      end

      def notify_time_capsule_released
        Publication.time_capsules.each do |publication|
          recipients = publication.family.users.where.not(id: publication.story.user_id)
          recipients.each do |recipient|
            ::MailerService.call(
              :time_capsule_released,
              params: {
                publisher: publication.story.user,
                recipient: recipient,
                time_capsule: publication
              }
            )
          end

          publication.update_attribute(:notified_at, Time.zone.now)
        end
      end

      def notify_appreciation(publication, user)
        return if user == publication.story.user

        ::MailerService.call(
          :appreciate_on_story,
          params: {
            user: user,
            publication: publication
          }
        )
      end
    end
  end
end
