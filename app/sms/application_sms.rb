class ApplicationSms
  attr_reader :client, :application_number

  def initialize(*)
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
    @application_number = ENV['TWILIO_NUMBER']
  end
end
