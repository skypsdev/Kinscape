Clearance.configure do |config|
  config.mailer_sender = 'Kinscape <welcome@kinscape.com>'
  config.routes = false
  config.cookie_name = "remember_token_#{Rails.env}"
  config.rotate_csrf_on_sign_in = false
end
