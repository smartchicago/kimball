json.array!(@twilio_wufoos) do |twilio_wufoo|
  json.extract! twilio_wufoo, :name, :wufoo_formid, :twilio_keyword
  json.url twilio_wufoo_url(twilio_wufoo, format: :json)
end