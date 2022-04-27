class EmailConfirmationsController < ApplicationController
  skip_before_action :require_login

  def create
    user = User.find_by!(email: params[:email])
    user.update!(confirmation_token: Clearance::Token.new)

    ::MailerService.call(
      :email_confirmation,
      params: {
        recipient: user,
        invitation_id: cookies[:invitation_id]
      }
    )

    flash[:success] = t('users.email_verification_instructions_sent')

    redirect_to sign_in_path
  end

  def update
    user = User.find_by!(confirmation_token: params[:token])
    user.confirm_email
    sign_in user

    if cookies[:invitation_id].present?
      redirect_to invitation_url(cookies[:invitation_id])
      cookies.delete :invitation_id
      return
    end

    redirect_to stories_path, notice: t('welcome.flash.upgrade_notice')
  end
end
