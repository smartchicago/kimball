# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  person_id    :integer
#  event_id     :integer
#  confirmed_at :datetime
#  created_by   :integer
#  attended_at  :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  updated_by   :integer
#

require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase

  setup do
    @reservation = reservations(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:reservations)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create reservation' do
    assert_difference('Reservation.count') do
      post :create, reservation: { attended_at: @reservation.attended_at, confirmed_at: @reservation.confirmed_at, created_by: @reservation.created_by, event_id: @reservation.event_id, person_id: @reservation.person_id }
    end

    assert_redirected_to reservation_path(assigns(:reservation))
  end

  test 'should show reservation' do
    get :show, id: @reservation
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @reservation
    assert_response :success
  end

  test 'should update reservation' do
    patch :update, id: @reservation, reservation: { attended_at: @reservation.attended_at, confirmed_at: @reservation.confirmed_at, created_by: @reservation.created_by, event_id: @reservation.event_id, person_id: @reservation.person_id }
    assert_redirected_to reservation_path(assigns(:reservation))
  end

  test 'should destroy reservation' do
    assert_difference('Reservation.count', -1) do
      delete :destroy, id: @reservation
    end

    assert_redirected_to reservations_path
  end

end
