json.array!(@reservations) do |reservation|
  json.extract! reservation, :person_id, :event_id, :aasm_state, :user_id,:time_slot_id
  json.url v2_reservation_url(reservation, format: :json)
end
