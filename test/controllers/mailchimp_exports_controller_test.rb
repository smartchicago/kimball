require 'test_helper'

class MailchimpExportsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should create new export" do
    assert_difference "MailchimpExport.count" do
      post :create, format: :js, mailchimp_export: { name: "test segment", recipients: ['foo@example.com', 'bar@eaxmple.com'] }
    end
    
    assert_response :success
  end

end
