module Invitations
  module OfflineMembers
    class SendingService < ApplicationService
      def initialize(kinship:, params:, current_user:)
        @kinship = kinship
        @family = kinship.family
        @params = params
        @current_user = current_user
        @recipient = params[:user_id].present? ? User.find(params[:user_id]) : User.find_by(email: params[:email])
      end

      def call
        return if recipient && family.users.include?(recipient)

        invitation = family.invitations.find_by(kinship: kinship)
        invitation ||= family.invitations.new(kinship: kinship)
        invitation.assign_attributes(
          email: recipient&.email || params[:email],
          role: params[:role],
          kinship: kinship,
          accepted_at: nil,
          message: params[:message] || '',
          sender: current_user,
          recipient: recipient
        )

        ::MailerService.call(:offline_member_to_active, params: { invitation: invitation }) if invitation.save
        invitation
      end

      private

      attr_reader :kinship, :family, :current_user, :params, :recipient
    end
  end
end
