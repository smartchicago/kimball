class V2::SmsReservationsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    send_error_notification && return unless only_numbers_and_at_least_two_of_them?

    if selection == 0
      send_decline_notifications(person, event)
    else
      reservation = V2::Reservation.create(person: person, time_slot: time_slot)
      send_notifications(person, reservation)
    end

    render text: 'OK'
  end

  private

    def message
      reservation_params[:Body]
    end

    def person
      @person ||= Person.find_by(phone_number: reservation_params[:From])
    end

    # TODO: needs to be smarter in the edge case where
    # there are more than 9 slot options and 0 comes up again
    def selection
      message.last.to_i
    end

    def event
      V2::Event.find(message.chop)
    end

    def time_slot
      event.time_slots[selection - 1]
    end

    def send_notifications(person, reservation)
      ::ReservationSms.new(to: person, reservation: reservation).send
    end

    def send_decline_notifications(person, event)
      ::DeclineInvitationSms.new(to: person, event: event).send
    end

    def send_error_notification
      ::InvalidOptionSms.new(to: reservation_params[:From]).send

      render text: 'OK'
    end

    def only_numbers_and_at_least_two_of_them?
      message =~ /^\d(\d)+\s?$/
    end

    def reservation_params
      params.permit(:From, :Body)
    end
end
