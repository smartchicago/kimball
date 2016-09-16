json.array!(@mailchimp_updates) do |mailchimp_update|
  json.extract! mailchimp_update, :raw_content, :email, :update_type, :reason, :fired_at
  json.url mailchimp_update_url(mailchimp_update, format: :json)
end