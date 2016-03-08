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
        EventInvitationMailer.invite(
          email_address: email_address,
          event: event_invitation.event,
          person: Person.find_by(email_address: email_address)
        ).deliver_later
      end
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
