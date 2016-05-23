# FIXME: Refactor
class V2::SmsReservationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate_user!

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    save_twilio_message # see receive_text_controller

    send_error_notification && return unless person

    # should do sms verification here if unverified

    # FIXME: this needs a refactor badly.
    if remove?
      # do the remove people thing.
      person.deactivate!
    elsif declined? # currently not used.
      #send_decline_notifications(person, event)
    elsif confirm? # confirmation for the days reservations
      if person.v2_reservations.for_today_and_tomorrow.size > 0
        person.v2_reservations.for_today_and_tomorrow.each(&:confirm!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif cancel?
      if person.v2_reservations.for_today_and_tomorrow.size > 0
        person.v2_reservations.for_today_and_tomorrow.each(&:cancel!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif change?
      if person.v2_reservations.for_today_and_tomorrow.size > 0
        person.v2_reservations.for_today_and_tomorrow.each(&:reschedule!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif calendar?
      ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today_and_tomorrow).send
    else
      str_context = Redis.current.get("wit_context:#{person.id}")

      # we don't know what event_id we're talking about here
      send_error_notification && return if str_context.nil?
      context = JSON.parse(str_context)
      new_context = ::WitClient.run_actions "#{person.id}_#{context['event_id']}", message, context
      Redis.current.set("wit_context:#{person.id}", new_context.to_json)
      Redis.current.expire("wit_context:#{person.id}", 3600)
    end
    render text: 'OK'
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

    def message
      sms_params[:Body]
    end

    def person
      @person ||= Person.find_by(phone_number: sms_params[:From])
    end

    def event_invitation
      @event_invitation ||= event.event_invitation
    end

    def user
      @user ||= event_invitation.user
    end

    def send_new_reservation_notifications(person, reservation)
      ::ReservationSms.new(to: person, reservation: reservation).send
      ReservationNotifier.notify(email_address: reservation.user.email, reservation: reservation).deliver_later
    end

    def send_decline_notifications(person, event)
      ::DeclineInvitationSms.new(to: person, event: event).send
    end

    def send_error_notification
      # awkward, yes, but see application_sms to understand why
      phone_struct = Struct.new(:phone_number).new(sms_params[:From])
      ::InvalidOptionSms.new(to: phone_struct).send

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
      message.downcase.include?('confirm')
    end

    def cancel?
      message.downcase.include?('cancel')
    end

    def change?
      message.downcase.include?('change') || message.downcase.include?('reschedule')
    end

    def calendar?
      message.downcase.include?('calendar')
    end

    def remove?
      message.downcase.include?('remove')
    end

    def sms_params
      params.permit(:From, :Body)
    end

    def twilio_params
      res = {}
      params.permit(:From, :To, :Body, :MessageSid, :DateCreated, :DateUpdated, :DateSent, :AccountSid, :WufooFormid, :SmsStatus, :FromZip, :FromCity,
        :FromState, :ErrorCode, :ErrorMessage, :Direction, :AccountSid).to_unsafe_hash.keys do |k, v|
        # behold the horror of translating twilio params to rails attributes
        res[k.gsub!(/(.)([A-Z])/, '\1_\2').downcase] = v
      end
      res
    end

    def save_twilio_message
      TwilioMessage.create(twilio_params)
    end
end
