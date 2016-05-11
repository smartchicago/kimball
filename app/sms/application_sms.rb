class ApplicationSms
  attr_reader :client, :application_number

  def initialize(*)
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
    @application_number = ENV['TWILIO_SCHEDULING_NUMBER']
  end

  def slot_id_to_char(id)
    raise ArgumentError if id >= 26
    (id + 97).chr
  end
end
