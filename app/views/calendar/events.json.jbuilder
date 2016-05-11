json.array!(@events) do |event|
  json.extract!     event, :id, :title, :description
  json.start        event.start_datetime
  json.end          event.end_datetime
  # this is because events have multiple time_slots
  if event.class.to_s == 'V2::Event'
    json.rendering    'background'
    json.modal_url    calendar_show_event_path(id: event.id, token: @visitor.token)
  else # it's a time slot
    json.modal_url    calendar_show_invitation_path(id: event.id, token: @visitor.token)
  end
  json.type event.class.to_s.demodulize
  # json.url event_url(event, format: :html)
end
