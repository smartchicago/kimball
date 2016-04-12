require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'coveralls'
Coveralls.wear_merged!('rails')

class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def wufoo_params
    {
      'Field1'       => 'Jim', # first name
      'Field2'       => 'Tester', # last name
      'Field10'      => 'jim@example.com',
      'Field153'     => 'No',  # voted
      'Field154'     => 'Yes', # called 311
      'Field39'      => 'Desktop computer', # type of primary
      'Field21'      => 'make model of primary', # desc of primary
      'Field40'      => 'Laptop',
      'Field24'      => 'make model of seconadry', # desc of secondary
      'Field41'      => 'magic connection', # connection type
      # 'Field27' =>  "other connection desc", # description of connection
      'Field53'      => 'In-person group', # participation type: In-person group
      'Field54'      => 'Remote observation', # participation type: Remote observation
      # 'Field31' =>  '3', # geography_id
      'Field44'      => '123123 Some St', # address_1
      'Field269'     => 'Chicago', # city
      'Field48'      => '54654', # postal_code
      'Field9'       => '9172153576', # phone_number
      'IP'           => '69.245.247.117', # client IP, ignored for the moment
      'HandshakeKey' => ENV['WUFOO_HANDSHAKE_KEY'] # secret code, ignored
    }
  end

end

class ActionController::TestCase

  include Devise::TestHelpers

  def setup
    @user = users(:admin)
    sign_in @user
  end

end

# keep this at the bottom, pls
require 'mocha/setup'
