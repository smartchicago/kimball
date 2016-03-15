class EventInvitationMailer < ApplicationMailer
  def invite(email_address:, event:, person:)
    admin_email = ENV['MAILER_SENDER']
    @email_address = email_address
    @event = event
    @person = person
    mail(to: email_address,
         bcc: admin_email,
         subject: 'Phone call interview')
  end
end
