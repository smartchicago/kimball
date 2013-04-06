require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should export csv" do
    get :index, :format => :csv
    assert_response :success
  end

end
