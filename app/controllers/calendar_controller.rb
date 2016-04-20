class CalendarController < ApplicationController
  skip_before_action :authenticate_user!, if: :person?
  include ActionController::MimeResponds

  def show
    # either it's a person or it's a user.
    @visitor = @person ? @person : current_user
    @reservations = @visitor.v2_reservations

    respond_to do |format|
      format.html {}
      format.ics {}
    end
  end

  def feed
  end

  private

    def person?
      if !allowed_params[:token].blank?
        @person = Person.find_by(token: allowed_params[:token])
      elsif !allowed_params[:id].blank?
        @person = Person.find_by(allowed_params[:id])
      end

      @person.nil? ? @person : false
    end

    def allowed_params
      params.permit(:token, :id, :event_id, :user_id)
    end
end
