module Invitations
  class SendingService < ApplicationService
    def initialize(family:, user_params:, current_user:, message:)
      @family = family
      @current_user = current_user
      @message = message
      @recipient = user_params[:id].present? ? User.find(user_params[:id]) : User.find_by(email: user_params[:email])
      @user_params = user_params
    end

    def call
      return { existing: user_params[:email] } if recipient && family.users.include?(recipient)

      @invitation = family.invitations.find_by(recipient: recipient) if recipient
      @invitation ||= family.invitations.new(recipient: recipient)
      @invitation.assign_attributes(
        email: recipient&.email || user_params[:email],
        role: user_params[:role],
        accepted_at: nil,
        message: message || '',
        sender: current_user
      )
      if @invitation.save
        send_mail
        { valid: user_params[:email] }
      else
        { invalid: user_params[:email] }
      end
    end

    private

    attr_reader :family, :current_user, :recipient, :user_params, :message

    def send_mail
      mail_type = recipient ? :existing_user_invitation : :invitation
      MailerService.call(mail_type, params: { invitation: @invitation })
    end
  end
end
