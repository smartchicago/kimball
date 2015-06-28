class TwilioMessagesController < ApplicationController
  before_action :set_twilio_message, only: [:show, :edit, :update, :destroy]

  # GET /twilio_messages
  # GET /twilio_messages.json
  def index
    @twilio_messages = TwilioMessage.all
  end

  # GET /twilio_messages/1
  # GET /twilio_messages/1.json
  def show
  end

  # GET /twilio_messages/new
  def new
    

  end

  # GET /twilio_messages/1/edit
  def edit
    @twilio_message.status = params['MessageStatus']
    @twilio_message.error_code = params['ErrorCode']
    @twilio_message.save
  end

  # POST /twilio_messages
  # POST /twilio_messages.json
  def create
    @twilio_message = TwilioMessage.new(twilio_message_params)
    @client = Twilio::REST::Client.new
    @twilio_message = TwilioMessage.new
    @client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: Logan::Application.config.twilio_number,
      body: 'Hey there!'

    )

    respond_to do |format|
      if @twilio_message.save
        format.html { redirect_to @twilio_message, notice: 'Twilio message was successfully created.' }
        format.json { render action: 'show', status: :created, location: @twilio_message }
      else
        format.html { render action: 'new' }
        format.json { render json: @twilio_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twilio_messages/1
  # PATCH/PUT /twilio_messages/1.json
  def update
    respond_to do |format|
      if @twilio_message.update(twilio_message_params)
        format.html { redirect_to @twilio_message, notice: 'Twilio message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @twilio_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twilio_messages/1
  # DELETE /twilio_messages/1.json
  def destroy
    @twilio_message.destroy
    respond_to do |format|
      format.html { redirect_to twilio_messages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twilio_message
      @twilio_message = TwilioMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twilio_message_params
      params.require(:twilio_message).permit(:message_sid)
    end
end
