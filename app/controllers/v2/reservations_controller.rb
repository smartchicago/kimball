# == Schema Information
#
# Table name: v2_reservations
#
#  id                  :integer          not null, primary key
#  time_slot_id        :integer
#  person_id           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer
#  event_id            :integer
#  event_invitation_id :integer
#

# FIXME: Refactor and re-enable cop
# rubocop:disable ClassLength
class V2::ReservationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_reservation_and_visitor, only: [:show,
                                                     :edit,
                                                     :update,
                                                     :destroy,
                                                     :confirm,
                                                     :cancel,
                                                     :change,
                                                     :show_actions,
                                                     :show_reservation,
                                                     :show_invitation]
  # need a before action here for authentication of reservation changes
  def new
    @person = Person.find_by(token: person_params[:token])

    redirect_to root_url unless @person

    @event_invitation = V2::EventInvitation.find_by(v2_event_id: event_params[:event_id])
    @user = @event_invitation.user
    @event = @event_invitation.event
    @available_time_slots = @event.available_time_slots(@person)
    @reservation = V2::Reservation.new(time_slot: V2::TimeSlot.new)
  end

  # rubocop:disable Metrics/MethodLength
  # TODO: refactor
  def create
    @reservation = V2::Reservation.new(reservation_params)
    if @reservation.save
      flash[:notice] = "An interview has been booked for #{@reservation.time_slot.to_weekday_and_time}"
      send_notifications(@reservation)
    else
      flash[:error] = "No time slot was selected, couldn't create the reservation"
    end
    @available_time_slots = []
    @person = @reservation.person
    respond_to do |format|
      format.js {}
      format.html { render :new }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # no authorization here. yet.

  def index
    @reservations = V2::Reservation.page(params[:page])
  end

  def show
    @comment = Comment.new commentable: @reservation
  end

  def edit
  end

  # these are our methods to
  def confirm
    if @reservation.confirm
      flash[:notice] = "You are confirmed for #{@reservation.to_weekday_and_time}, with #{@reservation.user.name}."
      @reservation.save
    else
      flash[:alert] = 'Error'
    end

    respond_to do |format|
      format.html { redirect_to calendar_path(token: @visitor.token, reservation_id: @reservation.id) }
      format.js { render text: "$('#reservationModal').modal('hide'); $('#calendar').fullCalendar( 'refetchEvents' );" }
    end
  end

  def cancel
    if @reservation.cancel
      flash[:notice] = 'Cancelled'
      @reservation.save
    else
      flash[:alert] = 'Error'
    end
    respond_to do |format|
      format.html { redirect_to calendar_path(token: @visitor.token, reservation_id: @reservation.id) }
      format.js { render text: "$('#reservationModal').modal('hide'); $('#calendar').fullCalendar( 'refetchEvents' );" }
    end
  end

  def change
    if @reservation.reschedule
      flash[:notice] = "#{@reservation.user.name} will be in touch soon to find a different time."
      @reservation.save
    else
      flash[:alert] = 'Error'
    end
    respond_to do |format|
      format.html { redirect_to calendar_path(token: @visitor.token, reservation_id: @reservation.id) }
      format.js { render text: "$('#reservationModal').modal('hide'); $('#calendar').fullCalendar( 'refetchEvents' );" }
    end
  end

  def update
    # flash a  notice here and return a js file that reloads the page
    # or calls turbolinks to reload or somesuch
    if @reservation.update(update_params)
      flash[:notice] = 'Reservation updated'
    else
      flash[:error]  = 'update failed'
    end

    respond_to do |format|
      format.html { redirect_to(:back) }
    end
  end

  def destroy
    @reservation.destroy!
    respond_to do |format|
      format.html { redirect_to v2_reservation_url }
      format.json { head :no_content }
    end
  end

  private

    def set_reservation_and_visitor
      unless params[:token].blank?
        @person = Person.find_by(token: params[:token])
        # if we don't have a person, see if we have a user's token.
        # thus we can provide a feed without auth1
        visitor
      end

      @reservation = V2::Reservation.find_by(id: params[:id])
      unless @reservation && @reservation.owner_or_invitee?(@visitor)
        return false
      end
      @visitor.nil? ? false : true
    end

    def visitor
      @visitor ||= @person ? @person : current_user
    end

    def send_notifications(reservation)
      ReservationNotifier.notify(
        email_address: reservation.person.email_address,
        reservation: reservation
      ).deliver_later
    end

    def event_params
      params.permit(:event_id)
    end

    def reservation_params
      params.require(:v2_reservation).permit(
        :person_id,
        :time_slot_id,
        :event_id,
        :event_invitation_id,
        :user_id,
        :aasm_event,
        :aasm_state)
    end

    def update_params
      params.permit(
        :id,
        :person_id,
        :time_slot_id,
        :event_id,
        :event_invitation_id,
        :user_id,
        :aasm_event,
        :aasm_state)
    end

    def person_params
      params.permit(:email_address, :person_id, :token)
    end

end
# rubocop:enable ClassLength
