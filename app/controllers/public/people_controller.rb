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
  # rubocop:disable Metrics/MethodLength
  def create
    @person = ::Person.new(person_params)
    @person.signup_at = Time.current

    success_msg = 'Thanks! We will be in touch soon!'
    error_msg   = "Oops! Looks like something went wrong. Please get in touch with us at <a href='mailto:#{ENV['MAILER_SENDER']}?subject=Patterns sign up problem'>#{ENV['MAILER_SENDER']}</a> to figure it out!"
    if @person.save
      msg =  success_msg
      add_tag(params[:age_range]) unless params[:age_range].blank?
      add_tag(params[:referral]) unless params[:referral].blank?
    else
      msg = error_msg
    end

    respond_to do |format|
      @msg = msg
      format.html { render action: 'create' }
    end
  end
  # rubocop:enable Metrics/MethodLength

  def deactivate
    @person =Person.find_by(token: d_params[:token])

    if @person && @person.id == d_params[:person_id].to_i
      @person.deactivate!('email')
    else
      redirect_to root_path
    end
  end

  private

    def d_params
      params.permit(:person_id, :token)
    end

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
        :token,
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

    def add_tag(tag)
      tag = Tag.find_or_initialize_by(name: tag)
      tag.created_by ||= 1 # first user.
      tag.save!
      Tagging.create(taggable_type: 'Person',
                     taggable_id: @person.id,
                     created_by: 1,
                     tag: tag)
    end
end
