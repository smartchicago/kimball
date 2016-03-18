class EventInvitationMailer < ApplicationMailer
  def invite(email_address:, event:, person:)
    admin_email = 'admin@what.host.should.we.have.here.com'
    @email_address = email_address
    @event = event
    @person = person
    @from = from
    mail(to: email_address,
         from: from,
         bcc: admin_email,
         subject: 'Phone call interview')
  end
end
