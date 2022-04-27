class UsersController < Clearance::UsersController
  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :invitation_id_cookie

  before_action :redirect_signed_in_users, only: [:create, :new, :new_alternative]
  skip_before_action :require_login, only: [:create, :new, :new_alternative], raise: false
  layout 'new_application', only: [:new, :create, :new_alternative]
  # rubocop:enable Rails/LexicallyScopedActionFilter
  WHITELIST_EMAILS = ['@kinscape.com', '@apiarydigital.com', '+kintest'].freeze

  ActionView::Base.field_error_proc = proc do |html_tag, _instance|
    # rubocop:disable Rails/OutputSafety
    html_tag.gsub('text-field__input', 'text-field__input text-field__input--error').html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def new_alternative
    @user = user_from_params
    render template: 'users/new_alternative'
  end

  def update
    return redirect_to '/account' if current_user.update(update_params)

    flash.now[:failure] = I18n.t('users.edit_profile.error_in_form')
    render 'accounts/show'
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def create
    return redirect_to(sign_up_path) if Rails.env.staging? && !whitelist_email

    @user = User.new(
      **create_params,
      confirmation_token: Clearance::Token.new,
      registration_method: registration_method,
      onboarding: User::ONBOARDING_DEFAULT
    )
    if verify_recaptcha_v3 || verify_recaptcha || Rails.env.development? # recaptcha v3 || recaptcha v2
      if @user.save
        send_email(@user)
        accept_invitation
        sign_in(@user)
        return redirect_to stories_path
      end

      return redirect_to(sign_in_path) if resend_mail
    else
      @show_checkbox_recaptcha = true unless verify_recaptcha_v3
    end

    template = request.referer&.include?('signup') ? 'users/new_alternative' : 'users/new'
    respond_to do |format|
      format.html { render template }
      format.json { render json: { errors: @user.errors.full_messages } }
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def destroy
    UserAccountDeleteJob.perform_later(current_user)
    flash[:notice] = I18n.t('users.destroy.notice')
  end

  private

  def invitation_id_cookie
    cookies[:invitation_id] = params[:invitation_id] if params[:invitation_id].present?
  end

  def verify_recaptcha_v3
    verify_recaptcha(action: 'signup', minimum_score: 0.5, secret_key: Global.recaptcha.secret_key_v3)
  end

  def whitelist_email
    WHITELIST_EMAILS.any? { |word| params.dig(:user, :email).include?(word) }
  end

  def resend_mail
    existing_user = User.find_by(email: @user[:email])
    return unless existing_user
    return if existing_user.confirmed_at
    return if existing_user.updated_at > 1.hour.ago

    existing_user.update!(confirmation_token: Clearance::Token.new)
    send_email(existing_user)
    invitation&.update(recipient: existing_user)
    flash[:notice] = I18n.t 'users.confirmation_resend'
  end

  def invitation
    @invitation ||= Invitation.find_by(id: cookies[:invitation_id])
  end

  def registration_method
    return :direct unless invitation
    return :offline if invitation.kinship
    return :follower if invitation.family.personal_access?

    :member
  end

  def create_params
    params.require(:user).permit(
      :email, :first_name, :last_name, :password, :password_confirmation, :terms_and_conditions
    )
  end

  def update_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  def send_email(user)
    ::MailerService.call(:email_confirmation, params: { recipient: user, invitation_id: cookies[:invitation_id] })
  end

  def accept_invitation
    return unless invitation

    invitation&.update(recipient: @user) && invitation.recipient.nil?
    ::Invitations::AcceptingService.call(invitation, { nickname: @user.name }, @user)
    cookies.delete :invitation_id
  end

  def redirect_signed_in_users
    return unless signed_in?
    return redirect_to invitation_url(params[:invitation_id]) if params[:invitation_id]

    redirect_to Clearance.configuration.redirect_url
  end
end
