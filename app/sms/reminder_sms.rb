# TODO: needs a spec.
# but a unit test would make coverage more robust
class ReminderSms < ApplicationSms
  attr_reader :to, :reservations
  handle_asynchronously :send # we queue up a bunch of these

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
      msg = ''
      reservations.each do|r|
        msg +=  "#{r.description} on #{r.to_weekday_and_time} for #{r.duration / 60} minutes with #{r.user.name} tel: #{r.user.phone_number}} \n"
      end
      msg
    end

    def generate_body
      msg = "You have #{r.size} reservations today.\n"
      msg += generate_res_msgs
      msg += "Reply 'Confirm' to confirm them all\n"
      msg += "Reply 'Cancel' to cancel them all\n"
      msg += "Reply 'Reschedule' to notify the other people to setup other times\n"
      msg += "You can send 'Calendar' at any time to see your schedule for the day"
      msg + 'Thanks!'
    end

end
