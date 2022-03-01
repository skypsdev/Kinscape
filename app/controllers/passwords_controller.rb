class PasswordsController < Clearance::PasswordsController
  before_action :clear_flash_msg

  def create
    @user = find_user_for_create

    if @user&.confirmed_at
      @user.forgot_password!
      ::MailerService.call(:reset_password, params: { recipient: @user })
    end
    flash.now[:alert] = 'If the email is in the database, then you will receive an email soon.'
    render template: 'passwords/new'
  end

  def update
    @user = find_user_for_update
    if password_params[:password] != password_params[:password_confirmation]
      flash.now[:alert] = "Doesn't Match Password"
      return render template: 'passwords/edit'
    end

    if @user.update_password(password_from_password_reset_params)
      @user.confirm_email
      sign_in @user
      session[:password_reset_token] = nil
      redirect_to url_after_update
    else
      flash_failure_after_update
      render template: 'passwords/edit'
    end
  end

  private

  def password_params
    permitted_attributes = [
      :password,
      :password_confirmation
    ]

    params.require(:password_reset).permit(*permitted_attributes)
  end

  def clear_flash_msg
    flash[:success] = nil
    flash[:alert] = nil
  end
end
