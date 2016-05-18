# TODO: needs a spec. The acceptance
# spec 'SMS invitation to phone call' covers it,
# but a unit test would make coverage more robust
class EventInvitationSms < ApplicationSms
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

  private

    # TODO: Chunk this into 160 characters and send individualls
    def body
      body = "#{event.description}\n"
      body << "If you're available please "
      body << " text back the number and letter of the time?\n\n"
      event.available_time_slots(to).each_with_index do |slot, i|
        body << "'#{event.id}#{slot_id_to_char(i)}' for #{slot.start_datetime_human}\n"
      end
      body << "If none of these times work, just ignore this.\n"
    end
end
