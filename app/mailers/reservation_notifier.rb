class ReservationNotifier < ApplicationMailer
  def notify(email_address:, reservation:)
    @email_address = email_address
    @reservation = reservation

    attachments['event.ics'] = { mime_type: 'application/ics', content: generate_ical(reservation) }

    mail(to: email_address,
         from: reservation.user.email,
         bcc: bcc_or_nil(email_address, reservation),
         subject: 'Interview scheduled',
         content_type: 'multipart/mixed')
  end

  def remind(email_address:, reservations:)
    @email_address = email_address
    @reservations = reservations

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, reservation),
         subject: 'Today\'s Interview Reminders',
         content_type: 'multipart/mixed')
  end

  def cancel(email_address:, reservation:)
    @email_address = email_address
    @reservation = reservation

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, reservation),
         subject: "Canceled: #{reservation.to_weekday_and_time}",
         content_type: 'multipart/mixed')
  end

  def confirm(email_address:, reservation:)
    @email_address = email_address
    @reservation = reservation

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, reservation),
         subject: "Confirmed: #{reservation.to_weekday_and_time}",
         content_type: 'multipart/mixed')
  end

  def reschedule(email_address:, reservation:)
    @email_address = email_address
    @reservation = reservation

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, reservation),
         subject: "Need to Reschedule: #{reservation.to_weekday_and_time}",
         content_type: 'multipart/mixed')
  end

  private

    # if the email is to the user, don't bcc!
    def bcc_or_nil(email_address, reservation)
      reservation.user.email == email_address ?  nil : reservation.user.email
    end

    # FIXME: Refactor and re-enable cop
    # rubocop:disable Metrics/MethodLength
    def generate_ical(reservation)
      cal = Icalendar::Calendar.new
      cal.event do |e|
        e.dtstart = Icalendar::Values::DateTime.new(reservation.start_datetime)
        e.dtend   = Icalendar::Values::DateTime.new(reservation.end_datetime)
        e.summary     = reservation.title
        e.description = reservation.description
        e.alarm do |a|
          a.summary = reservation.event.description
          a.trigger = '-P1DT0H0M0S' # 1 day before
        end
      end
      cal.publish
      cal.to_ical
    end
  # rubocop:enable Metrics/MethodLength
end
