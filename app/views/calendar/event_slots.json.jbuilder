json.array!(@objs) do |event|
  json.extract! event, :id, :title, :description
  json.user_id        event.user.id
  json.start          event.start_datetime
  json.end            event.end_datetime
  json.time_and_date  event.to_weekday_and_time
  json.type           event.class.to_s.demodulize
  # we need the time slot id if we want to save the reservation
  if event.class.to_s == 'V2::TimeSlot'
    json.event_id             event.event.id # yeah, I know.
    json.time_slot_id         event.id
    json.event_invitation_id  event.event_invitation.id
    json.person_id @visitor.id if @visitor.class.to_s == 'Person'
  end
  # this is because events have multiple time_slots
  json.rendering 'background' if event.class.to_s == 'V2::Event'
  # json.url event_url(event, format: :html)
end
