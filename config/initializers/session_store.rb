# Be sure to restart your server when you modify this file.

Logan::Application.config.session_store :cookie_store, key: '_logan_session', secure: (Rails.env.production? || Rails.env.staging?)
