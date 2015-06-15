require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should export csv" do
    get :index, :format => :csv, :q => "joe"
    assert_response :success
  end

  test "should search" do
    get :index, :q => "jim"
    assert_response :success
    assert_equal 1, assigns(:results).size
  end

end
