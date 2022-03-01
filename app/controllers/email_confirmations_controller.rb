class EmailConfirmationsController < ApplicationController
  skip_before_action :require_login

  def create
    user = User.find_by!(email: params[:email])
    user.update!(confirmation_token: Clearance::Token.new)

    ::MailerService.call(
      :email_confirmation,
      params: {
        recipient: user,
        invitation_id: params[:invitation_id]
      }
    )

    flash[:success] = t('users.email_verification_instructions_sent')

    redirect_to sign_in_path
  end

  def update
    user = User.find_by!(confirmation_token: params[:token])
    user.confirm_email

    # Temp. remove payment feature
    # Billing::SubscriptionService.subscribe(user)
    ::MailerService.call(
      :welcome_to_kinscape,
      params: { user: user }
    )

    sign_in user

    return redirect_to invitation_url(params[:invitation_id]) if params[:invitation_id].present?

    redirect_to welcome_path, notice: t('welcome.flash.upgrade_notice')
  end
end
