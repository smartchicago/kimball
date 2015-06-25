class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  skip_before_filter :authenticate_user!, if: :should_skip_janky_auth?
  skip_before_action :verify_authenticity_token, only: [:create]
  
  # GET /people
  # GET /people.json
  def index
    @people = Person.paginate(:page => params[:page]).order('signup_at DESC')
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @comment = Comment.new commentable: @person
    @reservation = Reservation.new person: @person
    @tagging = Tagging.new taggable: @person
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  # POST /people.json
  def create
    from_wufoo = false
    uatest = request.headers["User-Agent"]
    if uatest = "Wufoo.com"
    #if params['HandshakeKey'].present?
      if Logan::Application.config.wufoo_handshake_key != params['HandshakeKey']
        Rails.logger.warn("[wufoo] received request with invalid handshake. Full request: #{request.inspect}")
        head(403) and return
      end
      
      Rails.logger.info("[wufoo] received a submission from wufoo")
      from_wufoo = true
      @person = Person.initialize_from_wufoo(params)      
    else
      # creating a person by hand
      @person = Person.new(person_params)
    end
    
    respond_to do |format|
      if @person.save
        
        from_wufoo ? format.html { head :created } : format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render action: 'show', status: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
    
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.with_user(current_user).update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:first_name, :last_name, :email_address, :address_1, :address_2, :city, :state, :postal_code, :geography_id, :primary_device_id, :primary_device_description, :secondary_device_id, :secondary_device_description, :primary_connection_id, :primary_connection_description, :secondary_connection_id, :secondary_connection_description, :phone_number, :participation_type)
    end

    def should_skip_janky_auth?
      # don't attempt authentication on reqs from wufoo
      params[:action] == 'create' && params['HandshakeKey'].present?
    end
end
