class ConfirmedUserGuard < Clearance::SignInGuard
  def call
    if user_confirmed?
      next_guard
    elsif signed_in?
      failure I18n.t('users.verify_email')
    else
      failure I18n.t('flashes.failure_after_create')
    end
  end

  def user_confirmed?
    signed_in? && current_user.confirmed_at.present?
  end
end
