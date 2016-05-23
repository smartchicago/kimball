# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class ReservationCancelSms < ApplicationSms
  attr_reader :to, :reservation

  def initialize(to:, reservation:)
    super
    @to = to # only really people here.
    @reservation = reservation
  end

  def body
    "The #{duration} minute interview for #{selected_time}, with #{reservation.user.name} has been cancelled"
  end

  def selected_time
    reservation.time_slot.start_datetime_human
  end

  def duration
    reservation.duration / 60
  end
end
