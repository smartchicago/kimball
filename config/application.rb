require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

# this enables us to know who created a user or updated a user, I beleive.
require './lib/with_user'

module Logan

  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.autoload_paths += %W(#{config.root}/app/jobs #{config.root}/app/mailers #{config.root}/app/sms)

    # Analytics
    Logan::Application.config.google_analytics_enabled = false

    # compile the placeholder
    config.assets.precompile += %w( holder.js )

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      defaults = File.join(Rails.root, 'config', 'sample.local_env.yml')

      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exist?(env_file)

      # load in defaults unless they are already set
      YAML.load(File.open(defaults)).each do |key, value|
        ENV[key.to_s] = value unless ENV[key]
      end
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['TIME_ZONE'] || "Central Time (US & Canada)"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.generators do |g|
      g.test_framework :rspec
      g.jbuilder false
      g.assets false
      g.helper false
    end

  end

end
