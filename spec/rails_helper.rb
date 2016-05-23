ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'spec_helper'
require 'shoulda/matchers'
require 'database_cleaner'
require 'support/helpers'
require 'sms_spec'
require 'timecop'
require 'mock_redis'

SmsSpec.driver = :'twilio-ruby'

Redis.current = MockRedis.new # mocking out redis for our tests

ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # # show retry status in spec process
  # config.verbose_retry = true
  # # show exception that triggers a retry if verbose_retry is set to true
  # config.display_try_failure_messages = true

  # # run retry only on features
  # config.around :each, :js do |ex|
  #   ex.run_with_retry retry: 3
  # end

  config.include Helpers
  config.include SmsSpec::Helpers
  config.include SmsSpec::Matchers

  config.fixture_path = "#{::Rails.root}/test/fixtures"

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view

  config.filter_rails_from_backtrace!

  config.example_status_persistence_file_path = "#{::Rails.root}/tmp/rspec.data"

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    Redis.current.flushdb
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
