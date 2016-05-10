class CalendarController < ApplicationController
  # this is so that people can also visit the calendar.
  # identified by their secure token.
  skip_before_action :authenticate_user!, if: :person?

  include ActionController::MimeResponds

  def show
    @reservation = V2::Reservation.new
    redirect_to root_url unless visitor
  end

  def feed
    if visitor
      # TODO: refactor into calendarable.
      calendar = Icalendar::Calendar.new
      visitor.v2_reservations.each { |r| calendar.add_event(r.to_ics) }
      visitor.v2_events.each { |e| calendar.add_event(e.to_ics) }
      calendar.publish
      render text: calendar.to_ical
    else
      redirect_to root_url
    end
  end

  def reservations
    if visitor
      # TODO: refactor into reservations?
      @reservations = visitor.v2_reservations.joins(:event_invitation).where('v2_event_invitations.date BETWEEN ? AND ?', cal_params[:start], cal_params[:end])
    else
      redirect_to root_url
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def event_slots
    # events and their time slots.
    # TODO: refactor into user and person models with the same interface
    if visitor
      events = visitor.
               event_invitations.
               includes(event: :time_slots).
               where('date BETWEEN ? AND ?', cal_params[:start], cal_params[:end]).
               map(&:event).compact
      slots = []
      events.each do|e|
        if visitor.class.to_s == 'Person'
          e.available_time_slots(visitor).each { |ts| slots.push ts }
        else
          e.available_time_slots.each { |ts| slots.push ts }
        end
      end
      @objs = events + slots
    else
      redirect_to root_url
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def events
    redirect_to root_url unless current_user
    @events = current_user.
              events.
              joins(:event_invitation).
              includes(:v2_event_invitations).
              where('v2_event_invitations.date BETWEEN ? AND ?', cal_params[:start], cal_params[:end])
  end

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
        @person = Person.find_by(id: allowed_params[:id])
      end
      @person.nil? ? false : true
    end

    # both types can visit the page. they have the same interface
    def visitor
      @visitor ||= @person ? @person : current_user
    end

    def allowed_params
      params.permit(:token, :id, :event_id, :user_id, :type)
    end

    def cal_params
      # default the start of our calendar to today.
      end_time = (Time.zone.today + 7.days).strftime('%m/%d/%Y')
      start_time = Time.zone.today.strftime('%m/%d/%Y')

      defaults = { start: start_time, end: end_time }
      params.permit(:token, :start, :end).reverse_merge(defaults)

      # full calendar uses dashes, not slashes. argh.
      params.transform_values do |v|
        v =~ /\d{4}-\d{2}-\d{2}/ ? Time.zone.parse(v).strftime('%m/%d/%Y') : v
      end
    end
end
