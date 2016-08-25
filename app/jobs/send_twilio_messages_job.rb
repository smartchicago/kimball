# app/jobs/twilio/send_messages.rb
#
# module TwilioSender
# Send twilio messages to a list of phone numbers
#
# FIXME: Refactor and re-enable cop
# rubocop:disable Style/StructInheritance
#
class SendTwilioMessagesJob < Struct.new(:messages, :phone_numbers, :smsCampaign)

  def enqueue(job)
    # job.delayed_reference_id   =
    # job.delayed_reference_type = ''
    Rails.logger.info '[TwilioSender] job enqueued'
    job.save!
  end

  def max_attempts
    1
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  #
  def perform
    # Instantiate a Twilio client
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    Rails.logger.info "[TwilioSender#perform] Send #{messages} to #{phone_numbers}"
    if phone_numbers.present?

      phone_numbers.uniq!
      Rails.logger.info "[TwilioSender#perform] Send #{messages} to unique numbers - #{phone_numbers}"
      phone_numbers.reject! { |e| e.to_s.blank? }
      Rails.logger.info "[TwilioSender#perform] Send #{messages} to real numbers - #{phone_numbers}"
    else
      Rails.logger.warn "[TwilioSender#perform] phone_numbers is nil - #{phone_numbers}"
    end
    phone_numbers.each do |phone_number|
      phone_number = phone_number.strip.gsub('+1', '').delete('-')
      messages.each do |message|
        if message.present?
          begin
            message = message.strip

            @outgoing = TwilioMessage.new
            @outgoing.to = phone_number.gsub('+1', '').delete('-')
            @outgoing.body = message
            @outgoing.from = ENV['TWILIO_SURVEY_NUMBER'].gsub('+1', '').delete('-')
            @outgoing.wufoo_formid = smsCampaign
            @outgoint.direction = 'outgoing-survey'
            @outgoing.save

            phone_number = '+1' + phone_number.strip.gsub('+1', '').delete('-')

            # Create and send an SMS message
            @message = client.account.messages.create(
              from: ENV['TWILIO_SMS_SIGNUP_NUMBER'],
              to: phone_number,
              body: message
            )
            @outgoing.message_sid = @message.sid
            @outgoing.save
            Rails.logger.info("[Twilio][SendTwilioMessagesJob] #{phone_number}")
          rescue Twilio::REST::RequestError => e
            @outgoing.error_message = e.message
            @outgoing.save
            Rails.logger.warn("[Twilio][SendTwilioMessagesJob] had a problem. Full error: #{@outgoing.error_message}")
          end
        end
        sleep(1) # for twilio rate limiting, I presume.
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def before(job)
  end

  def after(job)
  end

  def success(job)
  end

end
# rubocop:enable Style/StructInheritance
