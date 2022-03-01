# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'rspec/retry'
require 'shoulda/matchers'
require 'webmock/rspec'
require 'clearance/rspec'
require 'capybara/rspec'
require 'support/vcr_config'

ActiveRecord::Migration.maintain_test_schema!

FFMPEG.logger = Logger.new(nil)

# rubocop:disable Lint/NonDeterministicRequireOrder
%w(support shared).each do |folder|
  Dir[Rails.root.join("spec/#{folder}/**/*.rb")].each { |file| require file }
end
# rubocop:enable Lint/NonDeterministicRequireOrder

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/last_examples.txt'
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    EncryptedActionText::Content.renderer = ActionText::Content.renderer
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(:each, :with_csrf_protection) do |example|
    orig = ActionController::Base.allow_forgery_protection

    begin
      ActionController::Base.allow_forgery_protection = true
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = orig
    end
  end

  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include ExternalRequests
  config.include HelperMethods
  config.include VueRoutesHelper

  config.include ActionView::Helpers::TranslationHelper, type: :feature
  config.include Features, type: :feature
  config.include Requests, type: :request
  config.include ActiveJob::TestHelper, type: :job

  config.include_context 'cookie', :cookie

  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
  config.use_transactional_fixtures = true

  config.filter_run_including focus: true unless ENV['CI']
  config.run_all_when_everything_filtered = true

  config.verbose_retry = true
  config.default_retry_count = 2
  config.exceptions_to_retry = [Net::ReadTimeout]
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
end

WebMock.disable_net_connect!(allow_localhost: true)
Delayed::Worker.delay_jobs = false
RSpec::Matchers.define_negated_matcher :avoid_changing, :change
