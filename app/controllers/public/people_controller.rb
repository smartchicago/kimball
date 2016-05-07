class Public::PeopleController < ApplicationController
  layout false
  after_action :allow_iframe
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # GET /people/new
  def new
    @referrer = false
    if params[:referrer]
      begin
        uri = URI.parse(params[:referrer])
        @referrer = params[:referrer] if uri.is_a?(URI::HTTP)
      rescue URI::InvalidURIError
        @referrer = false
      end
    end
    @person = ::Person.new
  end

  # POST /people
  def create
    @person = ::Person.new(person_params)
    @person.signup_at = Time.zone.now

    success_msg = 'Thanks! We will be in touch soon!'
    error_msg   = "Oops! Looks like something went wrong. Please get in touch with us at <a href='mailto:#{ENV['MAILER_SENDER']}?subject=Patterns sign up problem'>#{ENV['MAILER_SENDER']}</a> to figure it out!"

    respond_to do |format|
      @msg = @person.save ?  success_msg : error_msg
      format.html { render action: 'create' }
    end
  end

  private

    # rubocop:disable Metrics/MethodLength
    def person_params
      params.require(:person).permit(:first_name,
        :last_name,
        :email_address,
        :phone_number,
        :preferred_contact_method,
        :address_1,
        :address_2,
        :city,
        :state,
        :postal_code,
        :primary_device_id,
        :primary_device_description,
        :secondary_device_id,
        :secondary_device_description,
        :primary_connection_id,
        :primary_connection_description,
        :secondary_connection_id,
        :secondary_connection_description,
        :participation_type)
    end
    # rubocop:enable Metrics/MethodLength

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end
end
