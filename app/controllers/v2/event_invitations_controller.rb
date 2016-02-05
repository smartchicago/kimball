class V2::EventInvitationsController < ApplicationController
  def new
    @event_invitation = V2::EventInvitation.new
  end

  def create
    @event_invitation = V2::EventInvitation.new(event_invitation_params)

    if @event_invitation.save
      send_notifications(@event_invitation)
      flash[:notice] = 'Person was successfully invited.'
    else
      flash[:error] = 'There were problems with some of the fields.'
    end

    render :new
  end

  private

    def send_notifications(event_invitation)
      EventInvitationMailer.invite(
        email_address: event_invitation.email_address,
        event: event_invitation.event
      ).deliver_later
    end

    def event_invitation_params
      params.require(:v2_event_invitation).
        permit(
          :email_address,
          :description,
          :slot_length,
          :date,
          :start_time,
          :end_time
        )
    end
end
