require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, event: { address: @event.address, application_id: @event.application_id, capacity: @event.capacity, description: @event.description, ends_at: @event.ends_at, location: @event.location, name: @event.name, starts_at: @event.starts_at }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, id: @event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event
    assert_response :success
  end

  test "should update event" do
    patch :update, id: @event, event: { address: @event.address, application_id: @event.application_id, capacity: @event.capacity, description: @event.description, ends_at: @event.ends_at, location: @event.location, name: @event.name, starts_at: @event.starts_at }
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event
    end

    assert_redirected_to events_path
  end

  test "should export event" do
    MailchimpExport.any_instance.expects(:send_to_mailchimp).returns(true)

    assert_difference "MailchimpExport.count" do
      post :export, id: @event, format: :js
    end
    
    assert_response :success
  end
end
