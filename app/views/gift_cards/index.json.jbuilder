json.array!(@gift_cards) do |gift_card|
  json.extract! gift_card, :last_four, :expiration_date, :person_id, :notes, :created_by, :reason
  json.url gift_card_url(gift_card, format: :json)
end