# FIXME: Refactor
# rubocop:disable ClassLength
class V2::SmsReservationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate_user!

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    save_twilio_message # see receive_text_controller

    send_error_notification && return unless person
    PaperTrail.whodunnit = person # auditing
    Rails.logger.info "#{person.full_name}: #{message}"
    # should do sms verification here if unverified

    # FIXME: this if else bundle needs a refactor badly.
    if remove?
      # do the remove people thing.
      person.deactivate!('sms')
      person.save!
      ::RemoveSms.new(to: person).send
    elsif confirm? # confirmation for the days reservations
      if !person.v2_reservations.for_today_and_tomorrow.empty?
        person.v2_reservations.for_today_and_tomorrow.each(&:confirm!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif cancel?
      if !person.v2_reservations.for_today_and_tomorrow.empty?
        person.v2_reservations.for_today_and_tomorrow.each(&:cancel!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif change?
      if !person.v2_reservations.for_today_and_tomorrow.empty?
        person.v2_reservations.for_today_and_tomorrow.each(&:reschedule!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif calendar?
      ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today_and_tomorrow).send
    else

      # should be refactored into the person model.
      str_context = Redis.current.get("wit_context:#{person.id}")
      # we don't know what event_id we're talking about here
      send_error_notification && return if str_context.nil?
      context = JSON.parse(str_context)
      event_id = Redis.current.get("event_lock:#{person.id}") || Time.zone.today.to_s
      ::WitClient.run_actions "#{person.id}_#{event_id}_#{Rails.env}", message, context
    end
    # twilio wants an xml response.
    render text: '<?xml version="1.0" encoding="UTF-8" ?><Response></Response>'
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

    def message
      str = sms_params[:Body].force_encoding('utf-8').encode
      Emoji.replace_unicode_moji_with_name(str)
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

      render text: '<?xml version="1.0" encoding="UTF-8" ?><Response></Response>'
    end

    def resend_available_slots(person, event)
      ::TimeSlotNotAvailableSms.new(to: person, event: event).send
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
      # using a fancy twilio add on.
      # 1 thousandth of a penny to not piss people off.
      # https://www.twilio.com/marketplace/add-ons/mobilecommons-optout
      if params['AddOns']
        add_ons = JSON.parse(params['AddOns'])
        mobile_commons = add_ons['results']['mobilecommons_optout'] || nil
        if mobile_commons
          return true if mobile_commons['result']['probability'] >= 0.85
        end
      end
      false
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
# rubocop:enable ClassLength
