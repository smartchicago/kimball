require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @person = people(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      post :create, person: { address_1: @person.address_1, address_2: @person.address_2, city: @person.city, email_address: @person.email_address, first_name: @person.first_name, geography_id: @person.geography_id, last_name: @person.last_name, participation_type: @person.participation_type, phone_number: @person.phone_number, postal_code: @person.postal_code, primary_connection_description: @person.primary_connection_description, primary_connection_id: @person.primary_connection_id, primary_device_description: @person.primary_device_description, primary_device_id: @person.primary_device_id, secondary_device_description: @person.secondary_device_description, secondary_device_id: @person.secondary_device_id, state: @person.state }
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "should show person" do
    get :show, id: @person
    assert_response :success
  end

  test "should show person with no secondary connection info" do
    get :show, id: people(:two).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @person
    assert_response :success
  end

  test "should update person" do
    patch :update, id: @person, person: { address_1: @person.address_1, address_2: @person.address_2, city: @person.city, email_address: @person.email_address, first_name: @person.first_name, geography_id: @person.geography_id, last_name: @person.last_name, participation_type: @person.participation_type, phone_number: @person.phone_number, postal_code: @person.postal_code, primary_connection_description: @person.primary_connection_description, primary_connection_id: @person.primary_connection_id, primary_device_description: @person.primary_device_description, primary_device_id: @person.primary_device_id, secondary_device_description: @person.secondary_device_description, secondary_device_id: @person.secondary_device_id, state: @person.state }
    assert_redirected_to person_path(assigns(:person))
    
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, id: @person
    end

    assert_redirected_to people_path
  end

  test "should create via a wufoo POST" do
    assert_difference('Person.count') do
      post :create, wufoo_params
    end
    
    assert_response :created
  end
    
  test "should validate wufoo handshake key" do
    assert_no_difference('Person.count') do
      post :create, wufoo_params.merge("HandshakeKey" => "invalid")
    end
    
    assert_response 403
  end

  test "should accept submission without user auth" do
    sign_out @user
    
    assert_difference('Person.count') do
      post :create, wufoo_params
    end
    
    assert_response :created
  end

  test "unapproved user should not access index" do
    sign_in users(:not_approved)
    get :index
    assert_response :redirect
  end

  # test "twilio error message should save" do
  #   post :create, person: { address_1: @person.address_1, address_2: @person.address_2, city: @person.city, email_address: @person.email_address, first_name: @person.first_name, geography_id: @person.geography_id, last_name: @person.last_name, participation_type: @person.participation_type, phone_number: @person.phone_number, postal_code: @person.postal_code, primary_connection_description: @person.primary_connection_description, primary_connection_id: @person.primary_connection_id, primary_device_description: @person.primary_device_description, primary_device_id: @person.primary_device_id, secondary_device_description: @person.secondary_device_description, secondary_device_id: @person.secondary_device_id, state: @person.state }
    
  #   end
end
