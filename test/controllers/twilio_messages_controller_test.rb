# == Schema Information
#
# Table name: twilio_messages
#
#  id                 :integer          not null, primary key
#  message_sid        :string(255)
#  date_created       :datetime
#  date_updated       :datetime
#  date_sent          :datetime
#  account_sid        :string(255)
#  from               :string(255)
#  to                 :string(255)
#  body               :string(255)
#  status             :string(255)
#  error_code         :string(255)
#  error_message      :string(255)
#  direction          :string(255)
#  from_city          :string(255)
#  from_state         :string(255)
#  from_zip           :string(255)
#  wufoo_formid       :string(255)
#  conversation_count :integer
#  signup_verify      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

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
