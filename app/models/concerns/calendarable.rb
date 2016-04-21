require 'active_support/concern'

module Calendarable
  extend ActiveSupport::Concern

  def to_ics
    e               = Icalendar::Event.new
    e.dtstart       = Icalendar::Values::DateTime.new(start_datetime)
    e.dtend         = Icalendar::Values::DateTime.new(end_datetime)
    e.description   = description
    e.uid           = generate_ical_id
    add_alarm(e)
  end

  # for the calendar display
  def start_datetime
    return start_time.to_datetime if start_time.class == ActiveSupport::TimeWithZone
    date_plus_time(date, start_time)
  end

  def end_datetime
    return end_time.to_datetime if end_time.class == ActiveSupport::TimeWithZone
    date_plus_time(date, end_time)
  end

  private

    def add_alarm(e)
      # only add alarms for the actual reservation
      case self.class.name.demodulize
      when 'Reservation'
        generate_alarm(e)
      else
        e
      end
    end

    def generate_alarm(e)
      e.alarm do |a|
        a.attendee = generate_atendees
        a.summary  = description
        a.trigger  = '-P1DT0H0M0S' # 1 day before
      end
      e
    end

    def date_plus_time(date, time)
      (Date.strptime(date, '%m/%d/%Y').to_datetime + Time.zone.parse(time).seconds_since_midnight.seconds).to_datetime
    end

    def generate_atendees
      # some may not have a person.
      # this is only really used for reservations, so may be overkill
      user_email = user.nil? ? ENV['MAIL_ADMIN'] : user.email
      person_email = person.nil? ? nil : person.email_address
      [user_email, person_email].map { |at| "mailto:#{at}" }.compact!
    end

    # must by reasonably unique
    def generate_ical_id
      Digest::SHA1.hexdigest(id.to_s + start_time.to_s)
    end
end
