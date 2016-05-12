# TODO: needs a spec.
# but a unit test would make coverage more robust
class ReservationReminderSms < ApplicationSms
  attr_reader :to, :reservations

  def initialize(to:, reservations:)
    super
    @to = to
    @reservations = reservations
  end

  def send
    client.messages.create(
      from: application_number,
      to:   to.phone_number,
      body: generate_body
    )
  end

  private

    def generate_res_msgs
      msg = "You have #{res_count} reservation#{res_count > 1 ? 's': ''} today.\n"
      reservations.each do|r|
        msg +=  "#{r.description} on #{r.to_weekday_and_time} for #{r.duration / 60} minutes with #{r.user.name} tel: #{r.user.phone_number}} \n"
      end
      msg += "Reply 'Confirm' to confirm them all\n"
      msg += "Reply 'Cancel' to cancel them all\n"
      msg += "Reply 'Change' to reschedule and notify the other people to setup other times\n"
      msg += "You can send 'Calendar' at any time to see your schedule for today and tomorrow"
      msg += 'Thanks!'
    end

    def res_count
      @reservations.size
    end

    def generate_body
      if @reservations.blank?
        %(You have no reservations for today or tomorrow! )
      else
        generate_res_msgs
      end
    end

end
