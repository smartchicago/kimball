# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class TimeSlotNotAvailableSms < ApplicationSms
  attr_reader :to, :event

  def initialize(to:, event:)
    super
    @to = to
    @event = event
  end

  def send
    client.messages.create(
      from: application_number,
      to:   to.phone_number,
      body: body
    )
  end

  def body
    body = "Sorry, that time is not longer available for: \n"
    body << "#{event.description}\n"
    available_slots = event.available_time_slots(to)
    body << generate_slot_messages(available_slots)
    body << "\nThanks!\n\n"
    body << ENV['TEAM_NAME'] # TODO: signature should be configurable
  end

  # rubocop:disable Metrics/MethodLength,
  def generate_slot_messages(available_slots)
    msg = ''
    if available_slots.length >= 1
      msg << "If you'd like to still attend,"
      msg << ' would you so kind to select one of the possible times below,'
      msg << " by texting back its respective number?\n\n"
      available_slots.each_with_index do |slot, i|
        msg << "'#{event.id}#{slot_id_to_char(i)}' for #{slot.start_datetime_human}\n"
      end
      msg << "Or visit https://#{ENV['PRODUCTION_SERVER']}/calendar/?token=#{to.token} to pick a time.\n"
      msg << "If none of these times work you can just ignore this message.\n"
    else
      msg << "There are no more available times for this event.\n"
    end
    msg
  end
  # rubocop:enable Metrics/MethodLength,
end
