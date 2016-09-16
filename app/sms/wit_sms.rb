# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class WitSms < ApplicationSms
  attr_reader :to, :body

  def initialize(to:, msg:)
    super
    @to = to
    @msg = msg
  end

  def body
    @msg
  end
end
