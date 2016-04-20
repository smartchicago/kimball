require 'active_support/concern'

module Calendarable
  extend ActiveSupport::Concern

  def to_ics
    e               = Icalendar::Event.new
    e.dtstart       = generate_date_time(date, start_time)
    e.dtend         = generate_date_time(date, end_time)
    e.description   = description
    e.uid           = generate_ical_id
    add_alarm(e)
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

    def generate_date_time(date, time)
      # some start/end times are dates, others are not. Why?
      Icalendar::Values::DateTime.new(time)
    rescue Icalendar::Values::DateTime::FormatError
      datetime = Date.strptime(date, '%m/%d/%Y').to_datetime + Time.zone.parse(time).seconds_since_midnight.seconds
      Icalendar::Values::DateTime.new(datetime)
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
