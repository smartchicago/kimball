require 'active_support/concern'

module ToIcs
  extend ActiveSupport::Concern

  def to_ics
    e               = Icalendar::Event.new
    e.dtstart       = generate_date_time(date, start_time)
    e.dtend         = generate_date_time(date, end_time)
    e.description   = description
    e.uid           = generate_ical_id
    add_alarm(e)
  end

  def add_alarm(e)
    # only add alarms for the actual reservation
    generate_alarm(e) if self.class.name.demodulize == 'Reservation'
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
    datetime = Date.strptime(date, '%m/%d/%Y') + Time.zone.parse(time)
    Icalendar::Values::DateTime.new(datetime)
  end

  def generate_atendees
    # some may not have a person.
    # this is only really used for reservations, so may be overkill
    user_email = user.nil? ? nil : user.email
    person_email = person.nil? ? nil : person.email_address
    [user_email, person_email].compact.map { |at| "mailto:#{at}" }
  end

  # must by reasonably unique
  def generate_ical_id
    Digest::SHA1.hexdigest(id.to_s + start_time.to_s + event_id.to_s)
  end
end
