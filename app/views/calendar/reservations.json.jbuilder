json.array!(@reservations) do |res|
  json.extract! res, :id, :description, :title

  json.person_name    res.person.full_name
  json.person_number  res.person.phone_number
  json.person_email   res.person.email_address
  json.person_id      res.person.id
  json.time_and_date  res.to_weekday_and_time

  json.start          res.start_datetime
  json.end            res.end_datetime
  json.color          'red'
  json.type           res.class.to_s.demodulize
  #json.url event_url(event, format: :html)
end
