Clearance.configure do |config|
  config.mailer_sender = Global.clearance.mailer_sender
  config.routes = false
  config.cookie_name = Global.clearance.cookie_name
  config.rotate_csrf_on_sign_in = false
  config.sign_in_guards = [ConfirmedUserGuard]
end
