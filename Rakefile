require File.expand_path('config/application', __dir__)

if %w(development test).include? Rails.env
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

Kinscape::Application.load_tasks

task(:default).prerequisites.clear
task(:default).clear
task default: [:rubocop, :eslint, :spec]
