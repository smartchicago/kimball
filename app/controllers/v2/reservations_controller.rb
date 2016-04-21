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
    event = V2::Event.find_by(id: event_params[:event_id])
    @person = Person.find_by(token: person_params[:token])
    all_slots = event.available_time_slots
    @available_time_slots = filter_reservations([@person, event.user], all_slots)
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

    def filter_reservations(arr_obj, slots)
      arr_obj.each do |obj|
        slots = filter_obj_reservations(obj, slots)
      end
      slots
    end

    def filter_obj_reservations(obj, slots)
      unless slots.empty?
        res = obj.v2_reservations.joins(:time_slot).
              where('v2_time_slots.start_time >=?',
                DateTime.now.in_time_zone)

        # TODO: refactor
        # filtering out slots that overlap. Tricky.
        slots = slots.select do |s|
          res.any? { |r| not_overlaps(r, s) }
        end unless res.empty?
      end
      slots
    end

    def not_overlap?(one, other)
      !((one.start_time - other.end_time) * (other.start_time - one.end_time) >= 0)
    end

end
