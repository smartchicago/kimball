json.array!(@events) do |event|
  json.extract! event, :id, :title, :description
  json.start event.start_datetime
  json.end event.end_datetime
  # this is because events have multiple time_slots
  json.rendering 'background' if event.class.to_s == 'V2::Event'
  json.type event.class.to_s.demodulize
  # json.url event_url(event, format: :html)
end

