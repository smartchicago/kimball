json.array!(@reservations) do |res|
  json.extract! res, :id, :description
  json.start res.start_datetime
  json.end res.end_datetime
  json.type res.class.to_s.demodulize
  #json.url event_url(event, format: :html)
end
