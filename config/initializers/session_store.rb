# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
if Rails.env.production?
  Redu::Application.config.session_store :active_record_store,
    :key => "_#{Redu::Application.config.name}_session",
    :domain => "#{ENV['APP_URL']}"
else
  Redu::Application.config.session_store :active_record_store,
    :key => "_#{Redu::Application.config.name}_session"
end
