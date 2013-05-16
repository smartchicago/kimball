json.array!(@events) do |event|
  json.extract! event, :name, :description, :starts_at, :ends_at, :location, :address, :capacity, :application_id
  json.url event_url(event, format: :json)
end