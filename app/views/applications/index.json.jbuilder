json.array!(@applications) do |application|
  json.extract! application, :name, :description, :url, :source_url, :creator_name
  json.url application_url(application, format: :json)
end