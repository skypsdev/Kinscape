require_relative 'boot'
require 'action_cable/engine'
require 'rails'

%w(
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_text/engine
  sprockets/railtie
).each do |railtie|
  require railtie
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Global.configure do |config|
  config.environment      = Rails.env.to_s
  config.config_directory = File.expand_path('global', __dir__)
end

module Kinscape
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.active_storage.service_urls_expire_in = 1.hour

    config.active_record.default_timezone = :utc

    config.assets.precompile << ['*.png', '*.gif', '*.jpeg', '*.jpg', '*.svg']

    config.i18n.enforce_available_locales = true

    config.action_mailer.smtp_settings = Global.smtp.to_hash.symbolize_keys

    config.autoload_paths += Dir[Rails.root.join('app/models/**')]

    config.eager_load_paths << Rails.root.join('lib')

    config.assets.paths << Rails.root.join('node_modules')

    # https://github.com/sass/sassc-ruby/issues/207#issuecomment-675571476
    config.assets.configure do |env|
      env.export_concurrent = false
    end

    config.active_job.queue_adapter = :delayed_job
    config.generators.javascript_engine = :js

    overrides = Rails.root.join('app/overrides')
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end
  end
end

Rails.autoloaders.main.ignore(Rails.root.join('lib/generators'))
