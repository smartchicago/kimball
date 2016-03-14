require 'test_helper'

class ApplicationsControllerTest < ActionController::TestCase

  setup do
    @application = applications(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:applications)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create application' do
    assert_difference('Application.count') do
      post :create, application: { creator_name: @application.creator_name, description: @application.description, name: @application.name, source_url: @application.source_url, url: @application.url, program_id: programs(:one).id }
    end

    assert_redirected_to application_path(assigns(:application))
  end

  test 'should show application' do
    get :show, id: @application
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @application
    assert_response :success
  end

  test 'should update application' do
    patch :update, id: @application, application: { creator_name: @application.creator_name, description: @application.description, name: @application.name, source_url: @application.source_url, url: @application.url }
    assert_redirected_to application_path(assigns(:application))
  end

  test 'should destroy application' do
    assert_difference('Application.count', -1) do
      delete :destroy, id: @application
    end

    assert_redirected_to applications_path
  end

end
