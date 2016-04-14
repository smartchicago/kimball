class ReservationNotifier < ApplicationMailer
  def notify(email_address:, reservation:)
    admin_email = ENV['MAILER_SENDER']
    @email_address = email_address
    @reservation = reservation
    mail(to: email_address,
         from: admin_email,
         bcc: admin_email,
         subject: 'Interview scheduled')
  end
end
