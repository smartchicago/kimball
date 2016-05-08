class V2::SmsReservationsController < ApplicationController
  skip_before_action :authenticate_user!

  # rubocop:disable Metrics/MethodLength
  def create
    send_error_notification && return unless valid_message?
    if declined?
      send_decline_notifications(person, event)
    else
      reservation = V2::Reservation.new(generate_reservation_params)
      if reservation.save
        send_notifications(person, reservation)
      else
        resend_available_slots(person, event)
      end
    end
    render text: 'OK'
  end
  # rubocop:enable Metrics/MethodLength

  private

    def message
      sms_params[:Body]
    end

    def person
      @person ||= Person.find_by(phone_number: sms_params[:From])
    end

    # TODO: needs to be smarter in the edge case where
    # there are more than 9 slot options and 0 comes up again
    def selection
      slot_letter = message.downcase.delete('^a-z')
      # "a".ord - ("A".ord + 32) == 0
      # "b".ord - ("A".ord + 32) == 1
      # (0 + 97).chr == a
      # (1 + 97).chr == b
      slot_letter.ord - ('A'.ord + 32)
    end

    def event
      event_id = message.delete('^0-9')
      @event ||= V2::Event.includes(:event_invitation, :user, :time_slots).find_by(id: event_id)
    end

    def event_invitation
      @event_invitation ||= event.event_invitation
    end

    def user
      @user ||= event_invitation.user
    end

    def time_slot
      @event.time_slots[selection]
    end

    def generate_reservation_params
      { user: user,
        person: person,
        event: event,
        event_invitation: event_invitation,
        time_slot: time_slot }
    end

    def send_notifications(person, reservation)
      ::ReservationSms.new(to: person, reservation: reservation).send
    end

    def send_decline_notifications(person, event)
      ::DeclineInvitationSms.new(to: person, event: event).send
    end

    def send_error_notification
      ::InvalidOptionSms.new(to: sms_params[:From]).send

      render text: 'OK'
    end

    def resend_available_slots(person, event)
      ::TimeSlotNotAvailableSms.new(to: person, event: event).send
    end

    def declined?
      # this is no longer in use. still might be handt though...
      # up to 10k events.
      message.downcase =~ /^\d{1,5}-decline?/
    end

    def confirm?
      message.downcase =~ /^confirm?/
    end

    def cancel?
      message.downcase =~ /^confirm?/
    end

    def reschedule?
      message.downcase =~ /^reschedule?/
    end

    def calendar?
      message.downcase =~ /^calendar?/
    end
    # we probably want a method that will do the decline for us
    # cases:
    # 1) with reservation, it was a reminder, find reservation and cancel
    #     and send reservatino cancel message
    # 2) standard decline invitation, just send decline message to user and
    #    person

    def letters_and_numbers_only?
      # this is for accepting only. many messages now won't pass.
      # up to 10k events
      message.downcase =~ /\b\d{1,5}[a-z]\b/
    end

    # this needs to change. lots more potential valid messages
    def valid_message?
      return true if declined?
      return true if letters_and_numbers_only?
      false
    end

    def sms_params
      params.permit(:From, :Body)
    end
end
