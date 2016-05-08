# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class InvalidOptionSms < ApplicationSms
  attr_reader :to

  def initialize(to:)
    super
    @to = to
  end

  def send
    client.messages.create(
      from: application_number,
      to:   to,
      body: "Sorry, I didn't understand that! I'm just a computer..."
    )
  end
end
