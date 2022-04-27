class ApplicationController < ActionController::Base
  include Clearance::Controller
  include VueRoutesHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Temp. remove payment feature
  # before_action :require_subscription
  before_action :add_www_subdomain
  before_action :require_login

  helper_method :current_user?

  rescue_from ActiveRecord::RecordNotFound, with: :sign_in_with_other
  rescue_from CanCan::AccessDenied, with: :sign_in_with_other

  private

  def access_denied(_)
    redirect_to root_path
  end

  def url_after_denied_access_when_signed_out
    if request.original_fullpath.include?('/invitations/')
      cookies[:invitation_id] = request.original_fullpath.split('/').last
    end
    sign_in_url
  end

  def current_user
    super || Guest.new
  end

  def current_user?(user)
    user == current_user
  end

  def ensure_subscription_active
    return if family.active?

    redirect_to "/communities/#{family.id}/kinships",
                alert: t('flashes.alert.paused_subscription')
  end

  def sign_in_with_other
    redirect_to root_url, notice: t('flashes.sign_in_with_other')
  end

  def require_subscription
    return unless ENV['RENEW_SUBSCRIPTION'] == 'true'
    return unless signed_in?
    return if current_user.subscription

    sign_out
  end

  def add_www_subdomain
    return unless Rails.env.production?
    return if /^www/.match?(request.host)

    redirect_to(
      request.url.gsub(request.protocol, "#{request.protocol}www."),
      status: 301
    )
  end
end
