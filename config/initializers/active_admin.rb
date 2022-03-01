ActiveAdmin.setup do |config|
  config.site_title = 'Kinscape'
  config.authorization_adapter = ActiveAdmin::CanCanAdapter
  config.cancan_ability_class = 'Ability'
  config.on_unauthorized_access = :access_denied
  config.current_user_method = :current_user
  config.logout_link_path = :sign_out_path
  config.comments = false
  config.batch_actions = false
  config.localize_format = :long
end
