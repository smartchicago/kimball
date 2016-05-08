require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
Capybara.register_driver :poltergeist_debug do |app|
  options = {
    timeout: 30,
    inspector: true,
    window_size: [1280, 1440],
    port: 44678+ENV['TEST_ENV_NUMBER'].to_i,
    phantomjs_options: [
      '--proxy-type=none',
      '--load-images=no',
      '--ignore-ssl-errors=yes',
      '--ssl-protocol=any',
      '--web-security=false'
    ]
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.register_server :puma
Capybara.javascript_driver = :poltergeist_debug

# rubocop:disable all
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
# rubocop:enable all

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
