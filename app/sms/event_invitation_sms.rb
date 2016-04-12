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

    def body
      body = "Hello #{to.first_name},\n"
      body << "#{event.description}\n"

      body << "If you're available, would you so kind to select one of the possible times below,"
      body << " by texting back its respective number?\n\n"

      body << "#{event.id}0) Decline\n"
      event.available_time_slots.each_with_index do |slot, i|
        body << "#{event.id}#{i+1}) #{slot.to_time_and_weekday}\n"
      end

      body << "\nThanks in advance for you time!\n\n"

      # TODO: signature should be configurable
      body << 'Best, Kimball team'
    end
end
