# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class ReservationSms < ApplicationSms
  attr_reader :to, :reservation

  def initialize(to:, reservation:)
    super
    @to = to
    @reservation = reservation
  end

  def send
    [to.phone_number, application_number].each do |phone_number|
      client.messages.create(
        from: application_number,
        to:   phone_number,
        body: "An interview has been booked for #{selected_time}"
      )
    end
  end

  private

    def selected_time
      reservation.time_slot.to_weekday_and_time
    end
end