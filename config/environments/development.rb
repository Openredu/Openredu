# -*- encoding : utf-8 -*-
Redu::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Use Memcached as cache store, if caching is enabled
  config.cache_store = :dalli_store

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Nome e URL do app
  config.url = "localhost:3000"
  config.representer.default_url_options = {:host => "127.0.0.1:3000"}

  config.action_mailer.default_url_options = { :host => config.url }
  config.action_mailer.asset_host = "http://#{config.url}"

  # Armazena no sist. de arquivos
  config.paperclip = {
    :storage => :filesystem,
    :path => File.join(Rails.root.to_s, "public/images/:class/:attachment/:id/:style/:basename.:extension"),
    :url => "/images/:class/:attachment/:id/:style/:filename",
    :default_url => "/assets/missing_:class_:style.png"
  }

  config.paperclip_environment.merge!(config.paperclip)
  config.paperclip_user.merge!(config.paperclip)

  config.paperclip_documents = config.paperclip.merge({
    :styles => {},
    :default_url => ''
  })
  config.paperclip_myfiles = config.paperclip.merge({:styles => {}})
  config.video_original = config.paperclip.merge({:styles => {}})
  config.video_transcoded = config.paperclip.merge({:styles => {}})

  # Só converte os 5 primeiros segundos (grátis)
  config.zencoder[:test] = 1

 # Configurações do Pusher (redu-development app)
  config.pusher = {
  }

  # Configuração da aplicação em omniauth providers
  config.omniauth = {
    :facebook => {
      :app_id => ENV["FACEBOOK_APP_ID_DEV"],
      :app_secret => ENV["FACEBOOK_APP_SECRET_DEV"]
    },
    :google_oauth2 => {
      :app_id => ENV["GOOGLE_APP_ID_DEV"],
      :app_secret => ENV["GOOGLE_APP_SECRET_DEV"]
    }
  }

  # Configurações de VisClient
  config.vis_client = {
    :url => "http://localhost:4000/hierarchy_notifications.json",
    :host => "http://localhost:4000"
  }

  config.vis = {
    :subject_activities => "http://localhost:4000/subjects/activities.json",
    :lecture_participation => "http://localhost:4000/lectures/participation.json",
    :students_participation => "http://localhost:4000/user_spaces/participation.json"
  }

  Footnotes.run! if defined?(Footnotes)

  if defined?(Bullet)
    config.after_initialize do
      Bullet.enable = true
      Bullet.alert = true
      Bullet.bullet_logger = true
      Bullet.console = true
      Bullet.rails_logger = true
      Bullet.disable_browser_cache = true
    end
  end

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end


