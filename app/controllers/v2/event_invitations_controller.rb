class V2::EventInvitationsController < ApplicationController
  def new
    @event_invitation = V2::EventInvitation.new(email_addresses: params[:email_addresses])
  end

  def create
    @event_invitation = V2::EventInvitation.new(event_invitation_params)

    if @event_invitation.save
      send_notifications(@event_invitation)
      flash[:notice] = 'Person was successfully invited.'
    else
      errors = @event_invitation.errors.full_messages.join(', ')
      flash[:error] = 'There were problems with some of the fields: ' + errors
    end

    render :new
  end

  private

    def send_notifications(event_invitation)
      event_invitation.email_addresses_to_array.each do |email_address|
        person = Person.find_by(email_address: email_address)

        case person.preferred_contact_method.upcase
        when 'SMS'
          send_sms(event_invitation, person)
        when 'EMAIL'
          send_email(event_invitation, person)
        end
      end
    end

    def send_email(event_invitation, person)
      EventInvitationMailer.invite(
        email_address: person.email_address,
        event: event_invitation.event,
        person: person
      ).deliver_later
    end

    def send_sms(event_invitation, person)
      client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

      client.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: person.phone_number,
        body: sms_message(event_invitation, person)
      )
    end

    def sms_message(event_invitation, person)
      invitation_link = new_v2_reservation_url(
        email_address: person.email_address,
        event_id: event_invitation.event.id,
        token: person.token
      )

      <<-SMS
Hello, you've been invited to a phone interview

#{invitation_link}
      SMS
    end

    def event_invitation_params
      params.require(:v2_event_invitation).
        permit(
          :email_addresses,
          :description,
          :slot_length,
          :date,
          :start_time,
          :end_time
        )
    end
end
