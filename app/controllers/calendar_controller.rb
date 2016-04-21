class CalendarController < ApplicationController
  skip_before_action :authenticate_user!, if: :person?

  include ActionController::MimeResponds

  def show
    # either it's a person or it's a user.
    @visitor = @person ? @person : current_user
    if @visitor
      @reservations = @visitor.v2_reservations
    else
      redirect_to root_url
    end
  end

  def feed
    @visitor = @person ? @person : current_user
    if @visitor
      calendar = Icalendar::Calendar.new
      @visitor.v2_reservations.each { |r| calendar.add_event(r.to_ics) }
      calendar.publish
      render text: calendar.to_ical
    else
      redirect_to root_url
    end
  end

  private

    def person?
      if !allowed_params[:token].blank?
        @person = Person.find_by(token: allowed_params[:token])
        # if we don't have a person, see if we have a user's token.
        @person = User.find_by(token: allowed_params[:token]) if @person.nil?
      elsif !allowed_params[:id].blank?
        @person = Person.find_by(allowed_params[:id])
      end

      @person.nil? ? @person : false
    end

    def calendar_type
      case allowed_params[:type]
      when 'reservations'
        :v2_reservations
      when 'time_slots'
        :time_slots
      when 'event_invitations'
        :event_invitations
      else
        :v2_reservations
      end
    end

    def allowed_params
      params.permit(:token, :id, :event_id, :user_id, :type)
    end
end
