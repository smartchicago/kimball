json.array!(@programs) do |program|
  json.extract! program, :name, :description
  json.url program_url(program, format: :json)
end