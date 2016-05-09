# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class DeclineInvitationSms < ApplicationSms
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
      body: 'You have declined this invitation. Thanks for the heads-up.'
    )
    also_send_to_admin
  end

  private

    # TODO: event should probably have a title or name, so this notification
    # doesn't rely on the event id
    def also_send_to_admin
      client.messages.create(
        from: application_number,
        to:   application_number,
        body: "#{to.full_name} has declined the invitation for event #{event.id}. Thanks for the heads-up."
      )
    end
end
