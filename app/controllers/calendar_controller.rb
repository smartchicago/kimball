class CalendarController < ApplicationController
  skip_before_action :authenticate_user!, if: :person?

  include ActionController::MimeResponds

  def show
    redirect_to root_url unless visitor
  end

  def feed
    if visitor
      calendar = Icalendar::Calendar.new
      visitor.send(calendar_type).each { |r| calendar.add_event(r.to_ics) }
      calendar.publish
      render text: calendar.to_ical
    else
      redirect_to root_url
    end
  end

  def reservations
    if visitor
      @reservations = visitor.v2_reservations.joins(:time_slot).where('v2_time_slots.start_time >= ?', Time.zone.today)
    else
      redirect_to root_url
    end
  end

  # rubocop:disable metrics/MethodLength
  def event_slots
    # events and their time slots.
    # TODO: refactor into user and person models with the same interface
    if visitor
      events = visitor.event_invitations.where('date >=?', Time.zone.today.strftime('%m/%d/%Y')).map(&:event)
      slots = []
      events.each{|e|
        if visitor.class.to_s == 'Person'
          e.available_time_slots(visitor).each{|ts| slots.push ts }
        else
          e.available_time_slots.each{|ts| slots.push ts }
        end
      }
      @objs = events + slots
    else
      redirect_to root_url
    end
  end
  # rubocop:enable metrics/MethodLength

  private

    # this does the token based auth for users and persons
    def person?
      @person = nil
      if !allowed_params[:token].blank?
        @person = Person.find_by(token: allowed_params[:token])
        # if we don't have a person, see if we have a user's token.
        # thus we can provide a feed without auth1
        @person = User.find_by(token: allowed_params[:token]) if @person.nil?
      elsif !allowed_params[:id].blank?
        @person = Person.find_by(allowed_params[:id])
      end
      @person.nil? ? false : true
    end

    def calendar_type
      case allowed_params[:type]
      when 'reservations'
        :v2_reservations
      when 'time_slots'
        :time_slots
      when 'events'
        :v2_events
      when 'event_invitations'
        :event_invitations
      end
    end

    # this enables us to have the same interface for users and persons.
    def visitor
      @visitor ||= @person ? @person : current_user
    end

    def allowed_params
      params.permit(:token, :id, :event_id, :user_id, :type)
    end
end
