# TODO: needs a spec. The spec for SmsReservationsController covers it,
# but a unit test would make coverage more robust
class DeclineInvitationSms < ApplicationSms
  attr_reader :to, :event

  def initialize(to:, event:)
    super
    @to = to
    @event = event
  end

  private

    def body
      'You have declined this invitation. Thanks for the heads-up.'
    end

end
