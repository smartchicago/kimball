
class ApplicationSms
  attr_reader :client, :application_number, :to

  # need to generate urls here.
  include Rails.application.routes.url_helpers

  # how we figure out the right host
  host = ENV["#{Rails.env.upcase}_SERVER"].blank? ? 'localhost' : ENV["#{Rails.env.upcase}_SERVER"]
  Rails.application.routes.default_url_options[:host] = host

  def initialize(*)
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
    @application_number = ENV['TWILIO_SCHEDULING_NUMBER']
  end

  def send
    res = @client.messages.create(
      from: @application_number,
      to:   @to.phone_number,
      body: body
    )

    # log this outgoing message.
    # sms spec currently doesn't match twilio's return object
    TwilioMessage.create(twilio_params(res)) if Rails.env != 'test'
  end

  def body
    # this must be implemented in every subclass
    raise 'SubclassResponsibility'
  end

  private

    def twilio_params(res)
      { from:       @application_number,
        to:         @to.phone_number,
        body:       body,
        direction:  'outbound-api',
        date_sent:  Time.current,
        message_sid: res.sid,
        account_sid: res.account_sid,
        status:      res.status }
    end
end
