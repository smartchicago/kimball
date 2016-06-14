# FIXME: Refactor and re-enable cop
# rubocop:disable ClassLength
class ReceiveTextController < ApplicationController

  include GsmHelper

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  #
  def index
    @twilio_message = TwilioMessage.new
    @twilio_message.message_sid = params[:MessageSid]
    @twilio_message.date_created = params[:DateCreated]
    @twilio_message.date_updated = params[:DateUpdated]
    @twilio_message.date_sent = params[:DateSent]
    @twilio_message.account_sid = params[:AccountSid]
    @twilio_message.from = PhonyRails.normalize_number(params[:From])
    @twilio_message.to = PhonyRails.normalize_number(params[:To])
    @twilio_message.body = params[:Body]
    @twilio_message.status = params[:SmsStatus]
    @twilio_message.error_code = params[:ErrorCode]
    @twilio_message.error_message = params[:ErrorMessage]
    @twilio_message.direction = 'incoming-twiml'
    @twilio_message.save

    # from_number = params[:From].gsub('+1', '').delete('-').to_i # Removing +1 and converting to integer
    from_number = PhonyRails.normalize_number(params[:From])
    message = "Sorry, please try again. Text 'Hello' or 12345 to complete your signup! Or type 'Remove Me' to be removed from this list."
    if params[:Body].include?('12345') || params[:Body].downcase.include?('hello')
      @twilio_message.signup_verify = 'Verified'
      message = ENV['VERIFICATION_SMS_MESSAGE']
      this_person = Person.find_by(phone_number: from_number)
      this_person.verified = 'Verified by Text Message'
      this_person.save
      # Trigger add to Mailchimp list
      # mailChimpSend = Person.sendToMailChimp(this_person)
    elsif params['Body'].downcase.include?('remove me')
      @twilio_message.signup_verify = 'Cancelled'
      this_person = Person.find_by(phone_number: from_number)
      this_person.verified = 'Removal Request by Text Message'
      this_person.save
      message = "We are sorry for bothering you. You have been removed from the #{ENV['GROUP_NAME']}"
    end
    @twilio_message.save
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message message
    end
    respond_to do |format|
      format.xml { render xml: twiml.text }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockNesting
  #
  def smssignup
    # this is where surveys and new signups land.
    wufoo = WuParty.new(ENV['WUFOO_ACCOUNT'], ENV['WUFOO_API'])
    wufoo.forms

    session['counter'] ||= 0
    session['fieldanswers'] ||= {}
    session['fieldquestions'] ||= {}
    session['phone_number'] ||= PhonyRails.normalize_number(params[:From]) # Removing +1 and converting to integer
    session['contact'] ||= 'EMAIL'
    session['errorcount'] ||= 0
    session['formid'] ||= ''
    session['fields'] ||= ''
    session['form_length'] ||= 0
    session['form_type'] ||= ''
    session['end_message'] ||= ''

    message_body = params['Body'].strip
    sms_count = session['counter']
    fields = ''
    # if (session["formid"].is_a?(String) )
    #   @form = wufoo.form(session["formid"])
    #   fields = @form.flattened_fields
    # end

    @incoming = TwilioMessage.new
    @incoming.message_sid = params[:MessageSid]
    @incoming.date_sent = params[:DateSent]
    @incoming.account_sid = params[:AccountSid]
    @incoming.from = params[:From]
    @incoming.to = params[:To]
    @incoming.body = params[:Body].strip
    @incoming.status = params[:SmsStatus]
    @incoming.error_code = params[:ErrorCode]
    @incoming.error_message = params[:ErrorMessage]
    @incoming.direction = 'incoming-twiml'
    @incoming.save

    @twiliowufoo = TwilioWufoo.where('twilio_keyword = ? AND status = ?', params[:Body].strip.upcase, true).first

    message = 'Initial message'

    if message_body == '99999'
      message = 'You said 99999'
      session['counter'] = -1
      session['fieldanswers'] = {}
      session['fieldquestions'] = {}
      session['contact'] = 'EMAIL'
      session['errorcount'] = 0
      session['formid'] = ''
      session['fields'] = ''
      session['form_length'] = 0
      session['form_type'] ||= ''
      session['end_message'] ||= ''
    elsif @twiliowufoo && session['counter'] == 0
      session['formid'] = @twiliowufoo.wufoo_formid
      @form = wufoo.form(@twiliowufoo.wufoo_formid)
      fields = @form.flattened_fields
      session['form_length'] = fields.length
      message = (fields[session['counter']]['Title']).to_s
      message = to_gsm0338(message)
      session['form_type'] = @twiliowufoo.form_type
      session['end_message'] = @twiliowufoo.end_message
    elsif !@twiliowufoo && session['counter'] == 0
      message = 'I did not understand that. Please re-type your keyword.'
      session['counter'] -= 1

    elsif sms_count < (session['form_length'] - 2)
      @form = wufoo.form(session['formid'])
      fields = @form.flattened_fields
      id_to_store = fields[sms_count - 1]['ID']
      session['fieldanswers'][id_to_store] = message_body
      message = (fields[sms_count]['Title']).to_s
      message = to_gsm0338(message)
      # If the question asked for an email check if response contains a @ and . or a skip
      if fields[session['counter'] - 1]['Title'].include? 'email address'
        if !(params['Body'] =~ /.+@.+\..+/) && !(params['Body'].upcase.include? 'SKIP')
          message = "Oops, it looks like that isn't a valid email address. Please try again or text 'SKIP' to skip adding an email."
          session['counter'] -= 1
        end
      # If the question is a multiple choice using single letter response, check for single letter
      elsif fields[session['counter'] - 1]['Title'].include? 'A)'
        # if !( params["Body"].strip.upcase == "A")
        if !(params['Body'].strip.upcase =~ /A|B|C|D|E/)
          if session['errorcount'] == 0
            message = 'Please type only the letter of your answer. Thank you!'
            session['counter'] -= 1
            session['errorcount'] += 1
          elsif session['errorcount'] == 1
            message = 'Please type only the letter of your answer or type SKIP. Thank you!'
            session['counter'] -= 1
            session['errorcount'] += 1
          else
            session['errorcount'] = 0
          end
        else
          session['errorcount'] = 0
        end

      elsif fields[session['counter'] - 1]['Title'].include? 'receive notifications'
        session['contact'] = 'TEXT' if params['Body'].upcase.strip == 'TEXT'
      end

    elsif sms_count == (session['form_length'] - 2)
      @form = wufoo.form(session['formid'])
      fields = @form.flattened_fields
      session['fieldanswers'][fields[sms_count - 1]['ID']] = message_body
      session['fieldanswers'][fields[sms_count]['ID']] = session['phone_number']
      session['fieldanswers'][fields[sms_count + 1]['ID']] = session['form_type']
      @form.submit(session['fieldanswers'])
      if session['form_type'] == 'signup'
        message = ENV['SIGNUP_SMS_MESSAGE']
        message = ENV['SIGNUP_EMAIL_MESSAGE'] if session['contact'] == 'EMAIL'
      else
        message = if session['end_message'].length > 0
                    to_gsm0338(session['end_message'])
                  else
                    'Thank you. You have completed the form.'
                  end
      end
      # Reset session so that the texter can respond to future forms
      session['counter'] = -1
      session['fieldanswers'] = {}
      session['fieldquestions'] = {}
      session['contact'] = 'EMAIL'
      session['errorcount'] = 0
      session['formid'] = ''
      session['fields'] = ''
      session['form_length'] = 0
      session['form_type'] ||= ''
      session['end_message'] ||= ''
    else
      message = ENV['SIGNUP_ERROR_MESSAGE']
      # else

      #   #message = session["counter"]
      #   message = "2"
      #   #message = session["fields"]
      #   session["counter"] = -1
      #   session["fieldanswers"] = Hash.new
      #   session["fieldquestions"] = Hash.new
      #   session["contact"] = "EMAIL"
      #   session["errorcount"] = 0
    end

    # @incoming.save
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message message
    end
    respond_to do |format|
      format.xml { render xml: twiml.text }
    end
    session['counter'] += 1
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockNesting

end
# rubocop:enable ClassLength
