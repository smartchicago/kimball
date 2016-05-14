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
#  buffer          :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer
#

class V2::EventInvitationsController < ApplicationController
  def new
    # people_ids should come from a session.
    people_ids = session[:cart].blank? ? '' : session[:cart].uniq.to_s

    @event_invitation = V2::EventInvitation.new(people_ids: people_ids)
    @people = @event_invitation.people
  end

  def create
    @event_invitation = V2::EventInvitation.new(event_invitation_params)
    if @event_invitation.save
      send_notifications(@event_invitation)
      flash[:notice] = "#{@event_invitation.invitees.size} invitations sent!"
    else
      errors = @event_invitation.errors.full_messages.join(', ')
      flash[:error] = 'There were problems with some of the fields: ' + errors
    end

    render new_v2_event_invitation_path
  end

  def index
    @events = V2::EventInvitation.all.page(params[:page])
  end

  def show
    @event =  V2::EventInvitation.find_by(params[:id])
  end

  private

    def create_event(event_invitation)
      V2::Event.create(
        description: event_invitation.description,
        time_slots: event_invitation.break_time_window_into_time_slots,
        user_id: current_user || 1 # if nil, make admin owner
      )
    end

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
      params.require(:v2_event_invitation).permit(
        :people_ids,
        :description,
        :slot_length,
        :date,
        :start_time,
        :end_time,
        :buffer,
        :title,
        :user_id).merge(user_id: current_user.id)
    end
end
