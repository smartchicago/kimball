# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Logan::Application.load_tasks

if Rails.env != 'production' and Rails.env != 'staging'
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
  task test_with_coveralls: [:spec, :features, 'coveralls:push']

  task default: [:rubocop, :test, :spec, 'coveralls:push']
end
