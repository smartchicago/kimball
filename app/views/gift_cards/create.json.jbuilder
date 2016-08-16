json.array!(@gift_cards) do |gift_card|
  json.extract! gift_card, :gift_card_number, :expiration_date, :person_id, :notes, :created_by, :reason
  json.url gift_card_url(gift_card, format: :json)
end