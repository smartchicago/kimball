# FIXME: Refactor and re-enable cop
# rubocop:disable ClassLength
class CalendarController < ApplicationController
  # this is so that people can also visit the calendar.
  # identified by their secure token.
  skip_before_action :authenticate_user!, if: :person?

  include ActionController::MimeResponds

  def show
    @default_date = default_time
    @show_modal = modal_to_load
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

  def show_actions
    respond_to do |format|
      format.js
    end
  end

  def show_reservation
    visitor
    @reservation = V2::Reservation.find_by(id: allowed_params[:id])
    respond_to do |format|
      if @reservation.owner_or_invitee?(@visitor)
        format.js { }
      else
        flash[:error] = 'invalid option'
        format.js { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def show_invitation
    visitor
    @reservation = V2::Reservation.new
    @time_slot = V2::TimeSlot.find_by(id: allowed_params[:id])
    respond_to do |format|
      format.js
    end
  end

  def show_event
    visitor
    @event = V2::Event.find_by(id: allowed_params[:id])
    respond_to do |format|
      format.js
    end
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
      params.permit(:token,
                    :id,
                    :event_id,
                    :user_id,
                    :type,
                    :reservation_id,
                    :time_slot_id,
                    :default_time)
    end

    def event
      if allowed_params['event_id']
        @event ||= V2::Event.find_by(id: allowed_params['event_id'])
      end
    end

    def reservation
      if allowed_params['reservation_id']
        @reservation ||= V2::Reservation.find_by(id: allowed_params['reservation_id'])
      end
    end

    def time_slot
      if allowed_params['time_slot_id']
        @time_slot ||= V2::TimeSlot.find_by(id: allowed_params['time_slot_id'])
      end
    end

    def default_time
      return reservation.start_datetime.strftime('%F') if reservation
      return time_slot.start_datetime.strftime('%F') if time_slot
      return event.start_datetime.strftime('%F') if event
      if allowed_params['default_time']
        return Time.zone.parse(allowed_params['default_time']).strftime('%F')
      end
      Time.current.strftime('%F')
    end

    def modal_to_load
      return 'reservation' if reservation
      return 'time_slot' if time_slot
      return 'event' if event
      false
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
# rubocop:enable ClassLength
