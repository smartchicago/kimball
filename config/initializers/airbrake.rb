Airbrake.configure do |config|
  config.host = ENV['AIRBRAKE_HOST']
  config.project_id = 4 # required, but any positive integer works
  config.project_key = ENV['AIRBRAKE_KEY']

  # Uncomment for Rails apps
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end
