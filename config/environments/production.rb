# -*- encoding : utf-8 -*-
Redu::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = false

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Use Memcached as cache store (default config from ey)
  ## parse the memcached.yml
  #memcached_config = YAML.load_file(Rails.root.join('config/memcached.yml'))
  #memcached_hosts = memcached_config['defaults']['servers']
  ## pass the servers to dalli setup
  config.cache_store = :dalli_store#, *memcached_hosts

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  config.action_controller.asset_host = "0.0.0.0:3000"
  config.action_mailer.asset_host = config.action_controller.asset_host

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Nome e URL do app
  config.url = "0.0.0.0:3000"

  config.action_mailer.default_url_options = \
    { :host => config.url }
  config.representer.default_url_options = { :host => config.url }

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Remove cores do log
  config.colorize_logging = false
  
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
      :app_id => '191555477625856',
      :app_secret => '27e285f90a3ee1db7a3b61641ae14694'
    }
  }

  # Configurações de VisClient
  config.vis_client = {
    :url => "http://vis.redu.com.br/hierarchy_notifications.json"
  }

  config.vis = {
    :subject_activities => "http://vis.redu.com.br/subjects/activities.json",
    :lecture_participation => "http://vis.redu.com.br/lectures/participation.json",
    :students_participation => "http://vis.redu.com.br/user_spaces/participation.json"
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "email-smtp.us-east-1.amazonaws.com",
    :port => 465,
    :domain => 'redu.com.br',
    :authentication => :login,
    :user_name => 'AKIAINQ5Y2UPLZJQM3EA',
    :password => 'AqEmj6PTCT8HJCpUB9qmIXQb+G2SaKEFjKcWrR9MLUaF'
  }

  # Compress JavaScripts and CSS
  config.assets.compress = true
  
  #config.assets.precompile << /(^[^_\/]|\/[^_])[^\/]*$/

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true
end
