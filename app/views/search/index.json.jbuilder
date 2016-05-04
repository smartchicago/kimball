json.array!(@results) do |result|
  json.extract! result, :id, :first_name, :last_name, :email_address, :phone_number
  json.name [result.first_name, result.last_name].join(' ')
  json.tags result.tag_values
  json.url person_url(result.id, format: :html)
end
