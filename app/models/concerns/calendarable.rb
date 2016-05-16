require 'active_support/concern'

module Calendarable
  extend ActiveSupport::Concern

  def to_ics
    e               = Icalendar::Event.new
    e.summary       = title
    e.dtstart       = Icalendar::Values::DateTime.new(start_datetime)
    e.dtend         = Icalendar::Values::DateTime.new(end_datetime)
    e.description   = cal_description
    if defined? person
      e.url  = "https://#{ENV['PRODUCTION_SERVER']}/people/#{person.id}"
    end
    e.uid           = generate_ical_id
    add_alarm(e)
  end

  # for the calendar display
  def start_datetime
    return start_time if start_time.class == ActiveSupport::TimeWithZone
    date_plus_time(date, start_time)
  end

  def end_datetime
    return end_time if end_time.class == ActiveSupport::TimeWithZone
    date_plus_time(date, end_time)
  end

  def to_time_and_weekday
    "#{start_datetime.strftime('%R %p')} - #{end_datetime.strftime('%R %p')} #{start_datetime.strftime('%A %d')}"
  end

  def to_weekday_and_time
    "#{start_datetime.strftime('%R %p')} #{start_datetime.strftime('%R %p')} - #{end_datetime.strftime('%H:%M')}"
  end

  def start_datetime_human
    "#{start_datetime.strftime('%R %p, %a %b')} #{start_datetime.strftime('%d').to_i.ordinalize}"
  end

  private

    def cal_description
      if defined? person
        res  = description + "\n tel: #{person.phone_number}"
        res << " \n email: #{person.email_address}"
        return res
      else
        description
      end
    end

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
      (Date.strptime(date, '%m/%d/%Y') + Time.zone.parse(time).seconds_since_midnight.seconds)
    end

    def generate_atendees
      # some may not have a person.
      # this is only really used for reservations, so may be overkill
      user_email = defined? user ?  user.email : ENV['MAIL_ADMIN']
      person_email = defined? person ?  person.email_address : nil
      [user_email, person_email].map { |at| "mailto:#{at}" }.compact!
    end

    # must by reasonably unique
    def generate_ical_id
      Digest::SHA1.hexdigest(id.to_s + start_time.to_s)
    end
end
