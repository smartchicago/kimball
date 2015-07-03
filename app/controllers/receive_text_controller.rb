class ReceiveTextController < ApplicationController
	skip_before_filter :verify_authenticity_token 
    skip_before_filter :authenticate_user!
  def index 
        

    message_body = params["Body"]
    from_number = params["From"]
    
    @twilio_message = TwilioMessage.new
    @twilio_message.message_sid = params[:MessageSid]
    @twilio_message.date_created = params[:DateCreated]
    @twilio_message.date_updated = params[:DateUpdated]
    @twilio_message.date_sent = params[:DateSent]
    @twilio_message.account_sid = params[:AccountSid]
    @twilio_message.from = params[:From]
    @twilio_message.to = params[:To]
    @twilio_message.body = params[:Body]
    @twilio_message.status = params[:SmsStatus]
    @twilio_message.error_code = params[:ErrorCode]
    @twilio_message.error_message = params[:ErrorMessage]
    @twilio_message.direction = params[:Direction]
    @twilio_message.save

    from_number = params[:From].sub("+1","").to_i # Removing +1 and converting to integer
    message = "Hello"
    if params[:Body] == "12345"
      @twilio_message.signup_verify = "Verified"
      message = "Thank you for verifying your account."
      this_person = Person.find_by(phone_number: from_number)
      this_person.verified = true
      this_person.save
    elsif params["Body"] == "Remove me"
      @twilio_message.signup_verify = "Cancelled"
      this_person = Person.find_by(phone_number: from_number)
      this_person.verified = false
      this_person.save
      message = "Okay, we will remove you."
    end
    @twilio_message.save
    twiml = Twilio::TwiML::Response.new do |r|
       r.Message message
    end
    respond_to do |format|
      format.xml {render xml: twiml.text}
    end
  end
end
private
  def should_skip_janky_auth?
      # don't attempt authentication on reqs from wufoo
      params[:action] == 'create' && params['HandshakeKey'].present?
   end
end