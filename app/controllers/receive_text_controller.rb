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
    message = "Sorry, please try again. Text 'Hello' or 12345 to complete your signup!"
    if params[:Body].include? "12345" or params[:Body].downcase.include? 'hello'
      @twilio_message.signup_verify = "Verified"
      message = "Thank you for verifying your account. We will mail you your $5 VISA gift card right away."
      this_person = Person.find_by(phone_number: from_number)
      this_person.verified = "Verified by Text Message"
      this_person.save
      # Trigger add to Mailchimp list
      begin
        mailchimpSend = Gibbon.list_subscribe({:id => Logan::Application.config.cut_group_mailchimp_list_id, :email_address => this_person.email_address, :double_optin => 'false', :update_existing => 'true', :merge_vars => {:FNAME => this_person.first_name, :LNAME => this_person.last_name, :MMERGE3 => this_person.geography_id, :MMERGE4 => this_person.postal_code, :MMERGE5 => this_person.participation_type, :MMERGE6 => this_person.voted, :MMERGE7 => this_person.called_311, :MMERGE8 => this_person.primary_device_description, :MMERGE9 => this_person.secondary_device_id, :MMERGE10 => this_person.secondary_device_description, :MMERGE11 => this_person.primary_connection_id, :MMERGE12 => this_person.primary_connection_description, :MMERGE13 => this_person.primary_device_id}})
      rescue Gibbon::MailChimpError => e
          Rails.logger.fatal("[ReceiveTextController#index] fatal error sending #{this_person.id} to Mailchimp: #{e.message}")
      end
    elsif params["Body"] == "Remove me"
      @twilio_message.signup_verify = "Cancelled"
      this_person = Person.find_by(phone_number: from_number)
      this_person.verified = "Removal Request by Text Message"
      this_person.save
      message = "We are sorry for bothering you. You have been removed from the CUTGroup."
    end
    @twilio_message.save
    twiml = Twilio::TwiML::Response.new do |r|
       r.Message message
    end
    respond_to do |format|
      format.xml {render xml: twiml.text}
    end
  end

 def smssignup 
    wufoo = WuParty.new(ENV['WUFOO_ACCOUNT'],ENV['WUFOO_API'])
    wufoo.forms
    
    session["counter"] ||= 0
    session["fieldanswers"] ||= Hash.new
    session["fieldquestions"] ||= Hash.new
    session["phone_number"] ||= params[:From].sub("+1","").to_i # Removing +1 and converting to integer
    session["contact"] ||= "EMAIL"
    session["errorcount"] ||= 0

    message_body = params["Body"]

    @incoming = TwilioMessage.new
    @incoming.message_sid = params[:MessageSid]
    @incoming.date_created = params[:DateCreated]
    @incoming.date_updated = params[:DateUpdated]
    @incoming.date_sent = params[:DateSent]
    @incoming.account_sid = params[:AccountSid]
    @incoming.from = params[:From]
    @incoming.to = params[:To]
    @incoming.body = params[:Body]
    @incoming.status = params[:SmsStatus]
    @incoming.error_code = params[:ErrorCode]
    @incoming.error_message = params[:ErrorMessage]
    @incoming.direction = params[:Direction]
    @incoming.save

    form = wufoo.form(ENV['WUFOO_SIGNUP_FORM'])
    fields = form.flattened_fields
    #fieldids = Array.new
    
    @twiliowufoo = TwilioWufoo.where("twilio_keyword = ? AND status = ?", params[:Body], true).first


    if message_body == "99999"
      message = "You said 99999"
      session["counter"] = -1
      session["fieldanswers"] = Hash.new
      session["fieldquestions"] = Hash.new
      session["contact"] = "EMAIL"
      session["errorcount"] = 0

    elsif @twiliowufoo
      form = wufoo.form(@twiliowufoo.wufoo_formid)
      fields = form.flattened_fields    
      
      if session["counter"] == 0    
        message = "#{fields[session["counter"]]['Title']}"
      elsif session["counter"] < (fields.length - 1)
        session["fieldanswers"][fields[session["counter"]-1]['ID']] = params["Body"]
        message = "#{fields[session["counter"]]['Title']}"
        # If the question asked for an email check if response contains a @ and . or a skip
        if fields[session["counter"] - 1]['Title'].include? "email address"
          if !( params["Body"] =~ /.+@.+\..+/) and !(params["Body"].upcase.include? "SKIP")
            message = "Oops, it looks like that isn't a valid email address. Please try again or text 'SKIP' to skip adding an email."
            session["counter"] -= 1
          end
        # If the question is a multiple choice using single letter response, check for single letter  
        elsif fields[session["counter"] - 1]['Title'].include? "A)"
          #if !( params["Body"].strip.upcase == "A")
          if !( params["Body"].strip.upcase =~ /A|B|C|D/) 
            if session["errorcount"] == 0
              message = "Please type only the letter of your answer. Thank you!"
              session["counter"] -= 1
              session["errorcount"] += 1
            elsif session["errorcount"] == 1
              message = "Please type only the letter of your answer or type SKIP. Thank you!"
              session["counter"] -= 1
              session["errorcount"] += 1
            else
              session["errorcount"] = 0
            end
          else
            session["errorcount"] = 0
          end

        elsif fields[session["counter"] - 1]['Title'].include? "receive notifications"
          if params["Body"].upcase.strip == "TEXT"
            session["contact"] = "TEXT"
          end
        end
        
      elsif session["counter"] == (fields.length - 1) 
        session["fieldanswers"][fields[session["counter"]-1]['ID']] = params["Body"]
        session["fieldanswers"][fields[session["counter"]]['ID']] = from_number
        result = form.submit(session["fieldanswers"])
        message = "You are now signed up for CUTGroup! Your $5 gift card will be in the mail. When new tests come up, you'll receive a text from 773-747-6239 with more details."
        if session["contact"] == "EMAIL"
          message = "You are now signed up for CUTGroup! Your $5 gift card will be in the mail. When new tests come up, you'll receive an email from smarziano@cct.org with details."
        end
      else
        message = "You have already completed the sign up process."
      end  
    end
    
    @incoming.save
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message message
    end
    respond_to do |format|
      format.xml {render xml: twiml.text}
    end
    session["counter"] += 1
  end


end