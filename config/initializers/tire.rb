Tire.configure do
  if ENV['ELASTIC_SEARCH_URL'].blank?
    url 'http://localhost:9200'
  else
    url ENV['ELASTIC_SEARCH_URL']
  end
end
