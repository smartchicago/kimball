# TODO: needs a spec. The acceptance
# spec 'SMS invitation to phone call' covers it,
# but a unit test would make coverage more robust
class EventInvitationSms < ApplicationSms
  attr_reader :to, :event

  def initialize(to:, event:)
    super
    @to = to
    @event = event
  end

  # TODO: Chunk this into 160 characters and send individualls
  def body
    body = "#{event.description}\n"
    body << "If you're free for #{event.duration / 60} minutes at "
    body << "#{event.slot_time_human} please"
    body << " text back 'Yes' or 'No'\n"
  end
end
