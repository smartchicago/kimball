class EventInvitationMailer < ApplicationMailer
  def invite(email_address:, event:)
    admin_email = 'admin@what.host.should.we.have.here.com'
    @email_address = email_address
    @event = event
    mail(to: email_address,
         bcc: admin_email,
         subject: 'Phone call interview')
  end
end
