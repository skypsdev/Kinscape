module Kinships
  class NotificationService
    class << self
      def notify_members(kinship, user, changed_attr)
        chapter = kinship.chapters.find_by(id: changed_attr[:added_chapter]) if changed_attr[:added_chapter]
        recipients = kinship.family.users.where.not(id: user.id)
        recipients.each do |recipient|
          if changed_attr[:added_chapter]
            ::MailerService.call(
              :member_profile_updated_chapter,
              params: {
                publisher: kinship,
                recipient: recipient,
                chapter: chapter
              }
            )
          elsif changed_attr[:changed_generic]
            ::MailerService.call(
              :member_profile_updated_generic,
              params: {
                publisher: kinship,
                recipient: recipient
              }
            )
          end
        end
      end

      def notify_appreciation(appreciable)
        kinship = appreciable.chapterable_type.constantize.find_by(id: appreciable.chapterable_id)
        template = :appreciate_on_profile_chapter
        params = { kinship: kinship, chapter: appreciable }
        ::MailerService.call(template, params: params)
      end
    end
  end
end
