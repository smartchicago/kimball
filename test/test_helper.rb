ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include Devise::TestHelpers
  
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def wufoo_params
    {
      'Field1'  =>  'Jim', # first name
      'Field2'  =>  'Tester', # last name
      'Field10' =>  'jim@example.com',
      'Field14' =>  'No',  # voted
      'Field17' =>  'Yes', # called 311
      'Field20' =>  'Desktop computer', # type of primary
      'Field21' =>  'make model of primary', # desc of primary
      'Field23' =>  'Laptop',
      'Field24' =>  'make model of seconadry', # desc of secondary
      'Field26' =>  'Phone plan with data', # connection type
      'Field27' =>  "other connection desc", # description of connection
      'Field29' =>  'In-person group', # participation type
      'Field31' =>  '3', # geography_id
      'Field4'  =>  '123123 Some St', # address_1
      'Field7'  =>  '54654', # postal_code
      'Field9'  =>  '5646546543', # phone_number
      'IP'      =>  '69.245.247.117', # client IP, ignored for the moment
      'HandshakeKey' => 'b51c04fdaf7f8f333061f09f623d9d5b04f12b19' # secret code, ignored      
    }
  end
  
  def setup
    @user = users(:admin)
    sign_in @user
  end
  
end
