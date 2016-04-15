# == Schema Information
#
# Table name: v2_event_invitations
#
#  id              :integer          not null, primary key
#  v2_event_id     :integer
#  email_addresses :string(255)
#  description     :string(255)
#  slot_length     :string(255)
#  date            :string(255)
#  start_time      :string(255)
#  end_time        :string(255)
#

class V2::EventInvitationsController < ApplicationController
  def new
    @event_invitation = V2::EventInvitation.new(email_addresses: params[:email_addresses])
  end

  def create
    @event_invitation = V2::EventInvitation.new(event_invitation_params)
    #saving the current_user to the event
    @event_invitation.created_by = current_user.id

    if @event_invitation.save
      send_notifications(@event_invitation)
      flash[:notice] = 'Person was successfully invited.'
    else
      errors = @event_invitation.errors.full_messages.join(', ')
      flash[:error] = 'There were problems with some of the fields: ' + errors
    end

    render new_v2_event_invitation_path
  end

  private

    def send_notifications(event_invitation)
      event = event_invitation.event
      event_invitation.invitees.each do |invitee|
        case invitee.preferred_contact_method.upcase
        when 'SMS'
          send_sms(invitee, event)
        when 'EMAIL'
          send_email(invitee, event)
        end
      end
    end

    def send_email(person, event)
      EventInvitationMailer.invite(
        email_address: person.email_address,
        event:  event,
        person: person
      ).deliver_later
    end

    def send_sms(person, event)
      ::EventInvitationSms.new(to: person, event: event).send
    end

    # TODO: add a nested :event
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
