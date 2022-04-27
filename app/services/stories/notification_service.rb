module Stories
  class NotificationService
    class << self
      def notify_contribution(publication, user, changed_attr)
        publication.update(notified_at: Time.zone.now)
        section = publication.story.sections.find_by(id: changed_attr[:added_chapter]) if changed_attr[:added_chapter]
        recipients = publication.family.users.where.not(id: user.id)
        recipients.each do |recipient|
          if changed_attr[:added_chapter]
            ::MailerService.call(
              :story_updated_chapter_added,
              params: {
                publisher: user,
                recipient: recipient,
                publication: publication,
                section: section
              }
            )
          elsif changed_attr[:changed_generic]
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

      def notify_appreciation(appreciable, user, publication_id)
        template, params = nil
        if appreciable.instance_of?(Publication)
          return if user == appreciable.story.user

          template = :appreciate_on_story
          params = { user: user, publication: appreciable }
        elsif appreciable.instance_of?(Section)
          return if user == appreciable.author

          template = :appreciate_on_chapter
          params = { publication_id: publication_id, section: appreciable }
        end

        ::MailerService.call(template, params: params)
      end
    end
  end
end
