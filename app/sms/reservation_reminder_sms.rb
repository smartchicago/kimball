# TODO: needs a spec.
# but a unit test would make coverage more robust
class ReservationReminderSms < ApplicationSms
  attr_reader :to, :reservations

  def initialize(to:, reservations:)
    super
    @to = to
    @reservations = reservations
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def generate_res_msgs
    msg = "You have #{res_count} reservation#{res_count > 1 ? 's': ''} soon.\n"
    reservations.each do|r|
      next if r.end_datetime < Time.current # don't remind people of past events
      msg +=  "#{r.description} on #{r.start_datetime_human} for #{r.duration / 60} minutes with #{r.user.name} tel: #{r.user.phone_number} \n"
    end
    msg += "Reply 'Confirm' to confirm them all\n"
    msg += "Reply 'Cancel' to cancel them all\n"
    msg += "Reply 'Change' to request to reschedule\n"
    msg += "Reply 'Calendar' to see your schedule\n"
    msg += "You can always check online here:\n "
    msg += "#{calendar_url(token: to.token)}\n"
    msg += 'Thanks!'
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def res_count
    @reservations.size
  end

  def body
    if @reservations.blank?
      %(You have no reservations for today or tomorrow! )
    else
      generate_res_msgs
    end
  end

end
