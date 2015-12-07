require 'twilio-ruby'
require 'csv'

class TwilioMessagesController < ApplicationController
  before_action :set_twilio_message, only: [:show, :edit, :update, :destroy]
  #skip_before_action :verify_authenticity_token , only: [:newtwil]

  # GET /twilio_messages
  # GET /twilio_messages.json
  def index
    @twilio_messages = TwilioMessage.paginate(:page => params[:page]).order('updated_at DESC')
    @twilio_messages_help = TwilioMessage.where("'body' LIKE ?", 'HELP').paginate(:page => params[:page]).order('updated_at DESC')
    #@twilio_messages = TwilioMessage.all
  end

  def sendmessages
  end

  def uploadnumbers
    phone_numbers = []
    message1 = params.delete(:message1)
    message2 = params.delete(:message2)
    messages = Array[message1, message2]
    smsCampaign = params.delete(:twiliowufoo_campaign)
    infile = params[:file].read
   
    CSV.parse(infile, headers: true, header_converters: :downcase) do |row|
      #@person << row
      Rails.logger.info("[TwilioMessagesController#sendmessages] #{row}")
      phone_numbers.push(row["phone_number"])
    end

    Rails.logger.info("[TwilioMessagesController#sendmessages] messages #{messages}")
    Rails.logger.info("[TwilioMessagesController#sendmessages] phone numbers #{phone_numbers}")
     phone_numbers = phone_numbers.reject { |e| e.to_s.blank? }
     @job_enqueue = Delayed::Job.enqueue SendTwilioMessagesJob.new(messages, phone_numbers, smsCampaign)
     if @job_enqueue.save
       Rails.logger.info("[TwilioMessagesController#sendmessages] Sent #{phone_numbers} to Twilio")
       flash[:success] = "Sent Messages: #{messages} to Phone Numbers: #{phone_numbers}"
       respond_to do |format|
         format.html { redirect_to '/twilio_messages/sendmessages', notice: flash[:success] }
       end
     else
       Rails.logger.error("[TwilioMessagesController#sendmessages] failed to send text messages")
       format.all { render text: "failed to send text messages", status: 400} 
     end
  end



  # GET /twilio_messages/1
  # GET /twilio_messages/1.json
  def show
  end

  # GET /twilio_messages/new
  def new
  end

  # POST /twilio_messages/updatestatus
  def updatestatus
    this_message = TwilioMessage.find_by message_sid: params['MessageSid']
    this_message.status = params['MessageStatus']
    this_message.error_code = params['ErrorCode']
    this_message.save
  end

  # GET /twilio_messages/1/edit
  def edit
    @twilio_message.status = params['MessageStatus']
    @twilio_message.error_code = params['ErrorCode']
    @twilio_message.save
  end

  # POST /twilio_messages
  # POST /twilio_messages.json
  def newtwil  
    @twilio_message = TwilioMessage.new(twilio_message_params)
    #@twilio_message = TwilioMessage.new
    @twilio_message.message_sid = params[:Sid]
    @twilio_message.date_created = params[:DateCreated]
    @twilio_message.date_updated = params[:DateUpdated]
    @twilio_message.date_sent = params[:DateSent]
    @twilio_message.account_sid = params[:AccountSid]
    @twilio_message.from = params[:From].sub("+1","").sub("-","")
    @twilio_message.to = params[:To].sub("+1","").sub("-","")
    @twilio_message.body = params[:Body]
    @twilio_message.status = params[:Status]
    @twilio_message.error_code = params[:ErrorCode]
    @twilio_message.error_message = params[:ErrorMessage]
    @twilio_message.direction = params[:Direction]
    @twilio_message.save
    
    message = "Hello"
    if params[:Body] == "12345"
      @twilio_message.signup_verify = "Verified"
      message = "That you for verifying your account."
      this_person = Person.find_by phone_number: params[:From]
      this_person.verified = "True"
      this_person.save
    elsif params[:Body] = "Remove me"
      @twilio_message.signup_verify = "Cancelled"
      message = "Okay, we will remove you."
      this_person = Person.find_by phone_number: params[:From]
      this_person.verified = "False"
      this_person.save
    end
    @twilio_message.save
        
    twiml = Twilio::TwiML::Response.new do |r|
       r.Message message
    end
    #puts twiml.text
     respond_to do |format|
      format.xml {render xml: twiml.text}
     end
    #twiml.text
    #session["counter"] += 1

    #respond_to do |format|
    #   format.xml {render xml: twiml.text}
    #end

    # @client = Twilio::REST::Client.new
    # @twilio_message = TwilioMessage.new
    # @client.messages.create(
    #   from: ENV['TWILIO_NUMBER'],
    #   to: Logan::Application.config.twilio_number,
    #   body: 'Hey there!'

    # )

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

  # end
  # POST /twilio_messages/twil
  def create
    @twilio_message = TwilioMessage.new(twilio_message_params)
    @twilio_message.message_sid = params[:Sid]
    @twilio_message.date_created = params[:DateCreated]
    @twilio_message.date_updated = params[:DateUpdated]
    @twilio_message.date_sent = params[:DateSent]
    @twilio_message.account_sid = params[:AccountSid]
    @twilio_message.from = params[:From]
    @twilio_message.to = params[:To]
    @twilio_message.body = params[:Body]
    @twilio_message.status = params[:Status]
    @twilio_message.error_code = params[:ErrorCode]
    @twilio_message.error_message = params[:ErrorMessage]
    @twilio_message.direction = params[:Direction]
    @twilio_message.save
    
    
    #session["counter"] += 1

    #respond_to do |format|
    #   format.xml {render xml: twiml.text}
    #end

    # @client = Twilio::REST::Client.new
    # @twilio_message = TwilioMessage.new
    # @client.messages.create(
    #   from: ENV['TWILIO_NUMBER'],
    #   to: Logan::Application.config.twilio_number,
    #   body: 'Hey there!'

    # )

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
