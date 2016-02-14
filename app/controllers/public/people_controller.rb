class Public::PeopleController < ApplicationController
  after_action :allow_iframe
  skip_before_action :authenticate_user!

  # GET /people/new
  def new
    @referrer=request.env['HTTP_REFERER'] || false
    @person = ::Person.new
  end

  # POST /people
  def create
    @person = ::Person.new(person_params)

    respond_to do |format|
      if @person.save
        flash[:notice] = 'Person was successfully created.'
      else
        flash[:error] = 'There were problems with some of the fields.'
      end
      format.html { render action: 'new' }
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
