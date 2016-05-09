json.array!(@objs) do |obj|
  json.extract!       obj, :id, :title, :description
  json.user_id        obj.user.id
  json.start          obj.start_datetime
  json.end            obj.end_datetime
  json.time_and_date  obj.to_weekday_and_time
  json.type           obj.class.to_s.demodulize

  # we need the time slot id if we want to save the reservation
  if obj.class.to_s == 'V2::TimeSlot'
    color_id =  (((obj.event.id % 10 ) * 5).to_s.chars.map(&:to_i)[0])
    json.event_id             obj.event.id
    json.time_slot_id         obj.id
    json.event_invitation_id  obj.event_invitation.id

    # a consistent way to get a number from 0-5 from an event_id
    # same event_id  == same number from 0-5
    # ugly ugly hack.

    # a glorious array of kinda dumpy yellows
    slot_color = ['#D6D6C1', '#DEDEB9', '#E6E6B1', '#EEEEA9', '#F6F6A1', '#FFFF99'][color_id]
    json.textColor 'black'
    json.color     slot_color
    json.person_id @visitor.id if @visitor.class.to_s == 'Person'
  else # it's an event
    # glorious array of blues.
    color_id =  (((obj.id % 10 ) * 5).to_s.chars.map(&:to_i)[0])
    event_color = ["#C1C1D6", "#B9B9DE", "#B1B1E6", "#A9A9EE", "#A1A1F6", "#9999FF"][color_id]

    json.color      event_color
    json.rendering 'background'
    # json.url v2_event_url(obj, format: :html)
  end
end
