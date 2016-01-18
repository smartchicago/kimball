require 'test_helper'

class TwilioMessagesControllerTest < ActionController::TestCase

  setup do
    @twilio_message = twilio_messages(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:twilio_messages)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create twilio_message' do
    assert_difference('TwilioMessage.count') do
      post :create, twilio_message: { message_sid: @twilio_message.message_sid }
    end

    assert_redirected_to twilio_message_path(assigns(:twilio_message))
  end

  test 'should show twilio_message' do
    get :show, id: @twilio_message
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @twilio_message
    assert_response :success
  end

  test 'should update twilio_message' do
    patch :update, id: @twilio_message, twilio_message: { message_sid: @twilio_message.message_sid }
    assert_redirected_to twilio_message_path(assigns(:twilio_message))
  end

  test 'should destroy twilio_message' do
    assert_difference('TwilioMessage.count', -1) do
      delete :destroy, id: @twilio_message
    end

    assert_redirected_to twilio_messages_path
  end

end
