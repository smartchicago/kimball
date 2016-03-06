require 'test_helper'

class MailchimpExportsControllerTest < ActionController::TestCase

  test 'should get index' do
    get :index
    assert_response :success
  end

end
