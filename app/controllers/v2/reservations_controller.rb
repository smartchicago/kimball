# == Schema Information
#
# Table name: v2_reservations
#
#  id           :integer          not null, primary key
#  time_slot_id :integer
#  person_id    :integer
#
# TODO: status enum: tbd, reminded, cancelled, attended.

class V2::ReservationsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    event = V2::Event.find(event_params[:event_id])
    @event_owner = event.user
    @available_time_slots = event.available_time_slots
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

    def filter_obj_reservations(obj, slots)
      if slots.length > 0
        reservations = obj.reservations.joins('v2_time_slots').where('v2_time_slots.start_time >=?', DateTime.now.in_time_zone)
        slots = slots.select do |s|
          # if reservation.start
          reservations.any? do|r|
            overlaps?(r, s)
          end
        end
      end
      slots
    end

    def overlaps?(one, other)
      (one.start_time - other.end_time) * (other.start_time - one.end_time) >= 0
    end

end
