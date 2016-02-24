class ReservationNotifier < ApplicationMailer
  def notify(email_address:, reservation:)
    admin_email = 'admin@what.host.should.we.have.here.com'
    @email_address = email_address
    @reservation = reservation
    mail(to: email_address,
         bcc: admin_email,
         subject: 'Interview scheduled')
  end
end
