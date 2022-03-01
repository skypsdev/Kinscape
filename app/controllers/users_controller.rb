class UsersController < Clearance::UsersController
  # Temp. remove payment feature
  # before_action :set_plan, only: [:new, :create]

  def update
    if current_user.update(user_params)
      redirect_to '/after_account_update'
    else
      flash.now[:failure] = I18n.t 'users.edit_profile.error_in_form'
      # Temp. remove payment feature
      # @subscription = current_user.subscription
      # @families = current_user.families
      render 'accounts/show'
    end
  end

  def create
    return redirect_to(sign_up_path) if Rails.env.staging? && blacklisted_email

    @user = User.new(**user_params, confirmation_token: Clearance::Token.new)
    success_v3 = verify_recaptcha(action: 'signup', minimum_score: 0.5, secret_key: Global.recaptcha.secret_key_v3)
    if success_v3 || verify_recaptcha || Rails.env.development? # recaptcha v3 || recaptcha v2
      return send_mail_and_redirect if @user.save

      return redirect_to(sign_in_path(invitation_id: params[:invitation_id])) if resend_mail
    else
      @show_checkbox_recaptcha = true unless success_v3
    end
    render 'users/new'
  end

  def destroy
    UserAccountDeleteJob.perform_later(current_user)
    flash[:notice] = 'Your Account is deleting in a while, please wait.'
  end

  private

  def blacklisted_email
    email = params.dig(:user, :email)
    email.exclude?('@kinscape.com') && email.exclude?('@apiarydigital.com') && email.exclude?('+kintest')
  end

  def resend_mail
    existing_user = User.find_by(email: @user[:email])
    return unless existing_user
    return if existing_user.confirmed_at
    return if existing_user.updated_at < 1.hour.ago

    existing_user.update!(confirmation_token: Clearance::Token.new)
    ::MailerService.call(
      :email_confirmation,
      params: { recipient: existing_user, invitation_id: params[:invitation_id] }
    )
    Invitation.find_by(id: params[:invitation_id])&.update(recipient: existing_user)
    flash[:notice] = I18n.t 'users.confirmation_resend'
  end

  def send_mail_and_redirect
    ::MailerService.call(:email_confirmation, params: { recipient: @user, invitation_id: params[:invitation_id] })
    Invitation.find_by(id: params[:invitation_id])&.update(recipient: @user)
    flash[:notice] = I18n.t 'users.verify_email'
    redirect_to(sign_in_path(invitation_id: params[:invitation_id]))
  end

  def user_params
    permitted_attributes = [
      :email,
      :first_name,
      :last_name,
      *User::METADATA_FIELDS,
      { avatar_attributes: [
        :filename,
        :height,
        :id,
        :key,
        :mimetype,
        :type,
        :url,
        :width,
        :position,
        :size
      ] }
    ]

    params[:user][:lpage] = params[:lpage] if params[:lpage].present?
    permitted_attributes.push(:password, :password_confirmation) if params.dig(:user, :password)
    params[:user] && params.require(:user).permit(*permitted_attributes) || {}
  end

  def set_plan
    @plan = StripePlan.find_by(active: true) || Stripe::Plan.retrieve('basic')
  end
end
