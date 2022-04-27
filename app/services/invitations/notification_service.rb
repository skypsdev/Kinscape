module Invitations
  class NotificationService < ApplicationService
    def initialize(family, recipient = nil, offline_member: nil)
      @has_email = has_email
      @family = family
      @recipient = recipient
      @offline_member = offline_member
      @members = @family.kinships.filter_map(&:user)
    end

    def call
      ::MailerService.call(
        :user_joined_family,
        params: {
          recipients: members_emails,
          new_member: recipient || offline_member,
          family: family
        }
      )
    end

    private

    def members_emails
      members.filter_map do |member|
        next if member == @recipient

        "#{member.name} <#{member.email}>"
      end
    end

    def members_names
      members.map(&:name).join(', ')
    end

    attr_reader :recipient, :has_email, :family, :members, :offline_member
  end
end
