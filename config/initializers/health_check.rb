HealthCheck.setup do |config|
  config.success = 'success'
  config.http_status_for_error_text = 500
  config.http_status_for_error_object = 500
  # config.add_custom_check do
  #   CustomHealthCheck.perform_check # any code that returns blank on success and non blank string upon failure
  # end
end
