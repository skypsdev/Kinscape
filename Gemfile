source 'https://rubygems.org'

ruby '2.7.2'

gem 'activeadmin'
gem 'active_link_to'
gem 'active_model_serializers'
gem 'acts_as_list'
gem 'acts-as-taggable-on'
gem 'airbrake'
gem 'angularjs-rails-resource'
gem 'autoprefixer-rails', '6.7.0'
gem 'awesome_print'
gem 'aws-sdk-s3', require: false
gem 'bitters', require: false
gem 'bootsnap', require: false
gem 'bourbon'
gem 'cancancan'
gem 'clearance'
gem 'coffee-rails'
gem 'curb', require: false
gem 'delayed_job_active_record'
gem 'email_validator', require: false
gem 'encrypted_action_text', path: 'encrypted_action_text'
gem 'faraday'
gem 'flutie'
gem 'font-awesome-rails'
gem 'fx'
gem 'global', '0.1.2'
gem 'handlebars_assets'
gem 'high_voltage'
gem 'i18n-js', '3.2.1'
gem 'image_processing', require: false
gem 'intercom-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jsonapi-serializer'
gem 'jwt'
gem 'kaminari'
gem 'MailchimpMarketing'
gem 'MailchimpTransactional'
gem 'nokogiri', require: false
gem 'normalize-rails'
gem 'pagy'
gem 'pg'
gem 'puma', '4.3.6'
gem 'rack-reverse-proxy', require: 'rack/reverse_proxy'
gem 'rails', '~> 6.1.0'
gem 'rails-html-sanitizer', require: false
gem 'rake', require: false
gem 'recaptcha'
gem 'responders'
gem 'rswag-api'
gem 'rswag-ui'
gem 'rubyzip'
gem 'sanitize'
gem 'sassc-rails'
gem 'scout_apm'
gem 'simple_form'
gem 'slim'
gem 'streamio-ffmpeg'
gem 'stripe'
gem 'uglifier'
gem 'unread',
    git: 'https://github.com/ledermann/unread.git',
    ref: '083eef760cbebf724f8c8e7ff80efdb7f7f2a11e'
gem 'webpacker'
gem 'wicked_pdf'
gem 'zencoder'
gem 'zip_tricks', require: false

source 'https://rails-assets.org' do
  gem 'rails-assets-dotdotdot',   '1.8.3'
  gem 'rails-assets-flexslider',  '~>2.6.3'
  gem 'rails-assets-modernizr', '2.8.3'
  gem 'rails-assets-picturefill'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', require: false
  gem 'bullet'
  gem 'derailed', require: false
  gem 'erd', require: false
  gem 'foreman'
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-yarn', require: false
  gem 'letter_opener'
  gem 'memory_profiler'
  gem 'rack-mini-profiler'
  gem 'stackprof'
  gem 'wkhtmltopdf-binary'
end

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rswag'
  gem 'rswag-specs'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-selenium'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'geckodriver-helper', require: false
  gem 'launchy', require: false
  gem 'rspec-its'
  gem 'rspec-retry', require: false
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock', require: false
end

group :development, :staging, :test do
  gem 'active_record_query_trace'
  gem 'faker'
end

group :staging, :production do
  gem 'attr_kms',
      git: 'https://github.com/kinscape/attr_kms.git',
      branch: 'master'
  gem 'newrelic_rpm', '~>6.2'
  gem 'wkhtmltopdf-heroku', '2.12.5.0'
end

gem 'gem_bench', group: :console
gem 'redis'
