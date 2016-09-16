# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class RemoveSms < ApplicationSms
  attr_reader :to

  def initialize(to:)
    super
    @to = to # only really people here.
  end

  def body
    "You have been removed from this list. If you think this is in error, please contact #{ENV['MAIL_ADMIN']}"
  end
end
