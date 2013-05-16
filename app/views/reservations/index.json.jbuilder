json.array!(@reservations) do |reservation|
  json.extract! reservation, :person_id, :event_id, :confirmed_at, :created_by, :attended_at
  json.url reservation_url(reservation, format: :json)
end