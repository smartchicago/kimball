# app/jobs/twilio/send_messages.rb
#
# module TwilioSender
  # Send twilio messages to a list of phone numbers
  class SendTwilioMessagesJob < Struct.new(:messages, :phone_numbers)
  	def enqueue(job)
      # job.delayed_reference_id   = 
      # job.delayed_reference_type = ''
      Rails.logger.info ("[TwilioSender] job enqueued")
      job.save!
    end

    def max_attempts
      1
    end

    def perform
      # Instantiate a Twilio client
      client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
      
      phone_numbers = phone_numbers.uniq
      phone_numbers = phone_numbers.reject { |e| e.to_s.blank? }
      phone_numbers.each do |phone_number|
        phone_number = "+1" + phone_number.strip.sub("+1","").sub("-","")

	    messages.each do |message|
	      if message.present?
	        begin
	          message = message.strip

	          @outgoing = TwilioMessage.new
	          @outgoing.to = phone_number
    			  @outgoing.body = message
    			  @outgoing.from = ENV['TWILIO_NUMBER']
			  
    			  #@incoming.direction = "incoming-twiml"
    			  @outgoing.save

	          # Create and send an SMS message
	          @message = client.account.messages.create(
	            from: ENV['TWILIO_NUMBER'],
	            to: phone_number,
	            body: message
	          )
            @outgoing.message_sid = @message.sid
            @outgoing.save
            Rails.logger.info("[Twilio][SendTwilioMessagesJob] #{phone_number}")
	        rescue Twilio::REST::RequestError => e
			      @outgoing.error_message = e.message
	          @outgoing.save
	          Rails.logger.warn("[Twilio][SendTwilioMessagesJob] had a problem. Full error: #{error_message}")
	        end
	      end
	    end
      end
    end
    

    def before(job)
    end

    def after(job)
    end

    def success(job)
    end
  end
# end