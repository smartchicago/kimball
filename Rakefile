# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

unless Rails.env == 'production'
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
end

Logan::Application.load_tasks

task test_with_coveralls: [:spec, :features, 'coveralls:push']

task default: [:rubocop, :test, :spec, 'coveralls:push']
