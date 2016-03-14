require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  test 'should get index' do
    skip('Intermittently failing. https://github.com/BlueRidgeLabs/kimball/issues/14')
    get :index
    assert_response :success
  end

  test 'should export csv' do
    get :index, format: :csv, q: 'joe'
    assert_response :success
  end

  test 'should search' do
    skip('Intermittently failing. https://github.com/BlueRidgeLabs/kimball/issues/14')
    get :index, q: 'jim'
    assert_response :success
    assert_equal 1, assigns(:results).size
  end

end
