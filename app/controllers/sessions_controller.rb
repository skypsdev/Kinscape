class SessionsController < Clearance::SessionsController
  before_action :redirect_if_logged_in, only: [:create]

  # Temp. remove payment feature
  # after_action :check_subscription, only: [:create]
  rescue_from ActionController::InvalidAuthenticityToken,
              with: :redirect_if_logged_in

  def create
    @user = authenticate(params)

    sign_in(@user) do |status|
      return redirect_to invitation_url(params[:invitation_id]) if status.success? && params[:invitation_id].present?
      return redirect_back_or url_after_create if status.success?

      flash.now.alert = status.failure_message
      render template: 'sessions/new', status: 401
    end
  end

  protected

  def url_after_create
    stories_path
  end

  def url_for_signed_in_users
    stories_path
  end

  def check_subscription
    return unless signed_in?
    return if current_user.subscription

    Billing::SubscriptionService.subscribe(current_user)
  end

  def redirect_if_logged_in
    redirect_to url_for_signed_in_users if signed_in?
  end
end
