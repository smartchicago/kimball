# == Schema Information
#
# Table name: twilio_wufoos
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  wufoo_formid   :string(255)
#  twilio_keyword :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  status         :boolean          default(FALSE), not null
#  end_message    :string(255)
#  form_type      :string(255)
#

class TwilioWufoosController < ApplicationController

  before_action :set_twilio_wufoo, only: [:show, :edit, :update, :destroy]

  # GET /twilio_wufoos
  # GET /twilio_wufoos.json
  def index
    # @twilio_wufoos = TwilioWufoo.all
    @twilio_wufoos_active = TwilioWufoo.where(status: true)
    @twilio_wufoos_inactive = TwilioWufoo.where(status: false)
    @twilio_wufoos_signups = @twilio_wufoos_active.where(form_type: 'signup')
    @twilio_wufoos_others = @twilio_wufoos_active.where.not(form_type: 'signup')
  end

  # GET /twilio_wufoos/1
  # GET /twilio_wufoos/1.json
  def show
  end

  # GET /twilio_wufoos/new
  def new
    @twilio_wufoo = TwilioWufoo.new
    @maximum_length = TwilioWufoo.validators_on(:end_message).first.options[:maximum]
  end

  # GET /twilio_wufoos/1/edit
  def edit
  end

  # POST /twilio_wufoos
  # POST /twilio_wufoos.json
  def create
    @twilio_wufoo = TwilioWufoo.new(twilio_wufoo_params)

    respond_to do |format|
      if @twilio_wufoo.save
        format.html { redirect_to @twilio_wufoo, notice: 'Twilio wufoo was successfully created.' }
        format.json { render action: 'show', status: :created, location: @twilio_wufoo }
      else
        format.html { render action: 'new' }
        format.json { render json: @twilio_wufoo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twilio_wufoos/1
  # PATCH/PUT /twilio_wufoos/1.json
  def update
    respond_to do |format|
      if @twilio_wufoo.update(twilio_wufoo_params)
        format.html { redirect_to @twilio_wufoo, notice: 'Twilio wufoo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @twilio_wufoo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twilio_wufoos/1
  # DELETE /twilio_wufoos/1.json
  def destroy
    @twilio_wufoo.destroy
    respond_to do |format|
      format.html { redirect_to twilio_wufoos_url }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_twilio_wufoo
      @twilio_wufoo = TwilioWufoo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twilio_wufoo_params
      params.require(:twilio_wufoo).permit(:name, :wufoo_formid, :twilio_keyword, :status, :end_message, :form_type)
    end

end
