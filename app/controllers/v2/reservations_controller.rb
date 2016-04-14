# == Schema Information
#
# Table name: v2_reservations
#
#  id           :integer          not null, primary key
#  time_slot_id :integer
#  person_id    :integer
#

class V2::ReservationsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    event = V2::Event.find(event_params[:event_id])
    @available_time_slots = event.available_time_slots.page(params[:page])
    @person = Person.find_by(token: person_params[:token])
    @reservation = V2::Reservation.new(time_slot: V2::TimeSlot.new)
  end

  def create
    @reservation = V2::Reservation.new(reservation_params)

    if @reservation.save
      flash[:notice] = "An interview has been booked for #{@reservation.time_slot.to_weekday_and_time}"

      send_notifications(@reservation)
    else
      flash[:error] = "No time slot was selected, couldn't create the reservation"
    end

    @available_time_slots = []
    @person = @reservation.person

    render :new
  end

  private

    def send_notifications(reservation)
      ReservationNotifier.notify(
        email_address: reservation.person.email_address,
        reservation: reservation
      ).deliver_later
    end

    def event_params
      params.permit(:event_id)
    end

    def reservation_params
      params.require(:v2_reservation).permit(:person_id, :time_slot_id)
    end

    def person_params
      params.permit(:email_address, :person_id, :token)
    end
end
