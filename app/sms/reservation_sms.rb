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
    client.messages.create(
      from: application_number,
      to:   to.phone_number,
      body: body
    )
  end

  private

    def body
      "A #{duration} minute interview has been booked for:\n#{selected_time}\nWith: #{reservation.user.name}, \nTel: #{reservation.user.phone_number}\n.You'll get a reminder that morning."
    end

    def selected_time
      reservation.time_slot.start_datetime_human
    end

    def duration
      reservation.duration / 60
    end
end
