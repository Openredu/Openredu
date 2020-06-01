# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'oauth/rack/oauth_filter'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Redu
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Brasilia'

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      "<div class='control-error field_with_errors'>#{html_tag}</div>".html_safe
    }

    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec
      g.fixture_replacement :factory_girl
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    if File.exists?( File.join(Rails.root, 'config', 'application.yml') )
      file = File.join(Rails.root, 'config', 'application.yml')
      config.extras = YAML.load_file file
    end

    # MimeTypes
    if File.exists? File.join(Rails.root, 'config', 'mimetypes.yml')
      file = File.join(Rails.root, 'config', 'mimetypes.yml')
      config.mimetypes = YAML.load_file file
    end

    # Meta dados da aplicação
    config.name = "Openredu"
    config.tagline = "Rede Social Educacional"
    config.description = "Rede Social Educacional"
    config.email = "contato@openredu.com"
    config.path = "openredu.ufpe.br"

    # Nome e URL do app
    config.url = ENV['APP_URL']

    # Paginação
    config.items_per_page = 10

    # Máximo de caracteres p/ descrição
    config.desc_char_limit = 200

    config.faye_url = ENV['FAYE_URL']
    config.faye_js_url = "#{config.faye_url}/client.js"

    config.session_store = :active_record_store
    config.representer.default_url_options = {:host => ENV['API_URL']}

    # ActionMailer
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :test
    config.action_mailer.default_url_options = { :host => config.url }

    config.paperclip = {
      :storage => :filesystem,
      :path => File.join(Rails.root.to_s, "public/images/:class/:attachment/:id/:style/:basename.:extension"),
      :url => "/images/:class/:attachment/:id/:style/:filename",
      :default_url => "/assets/missing_:class_:style.png"
    }

    config.paperclip_environment = config.paperclip.merge({
      :styles => { :thumb_32 => "32x32#",
                   :thumb_90 => "90x90#",
                   :thumb_140 => "140x140#" }
    })

    config.paperclip_user = config.paperclip.merge({
      :styles => { :thumb_24 => "24x24#",
                   :thumb_32 => "32x32#",
                   :thumb_48 => "48x48#",
                   :thumb_64 => "64x64#",
                   :thumb_90 => "90x90#",
                   :thumb_110 => "110x110#",
                   :thumb_160 => "160x160#" }
    })

    config.paperclip_documents = config.paperclip.merge({
      :styles => {},
      :default_url => ''
    })

    config.paperclip_myfiles = config.paperclip.merge({
      :storage => :filesystem,
      :path => File.join(Rails.root.to_s, "public/files/:class/:attachment/:id/:style/:basename.:extension"),
      :default_url => ":class/:attachment/:style/missing.png",
      :styles => {}
    })

    # Configurações de conversão e storage de videos (Seminar)
    config.video_original = { # Arquivo original do video (uploaded)
      :storage => :filesystem,
      :path => File.join(Rails.root.to_s, "public/video_original/:class/:attachment/:id/:style/:basename.:extension"),
      :url => "/images/:class/:attachment/:id/:style/:filename",
      :default_url => ":class/:attachment/:style/missing.png",
      :styles => {}
    }

    config.video_transcoded = { # Arquivo convertido
      :storage => :filesystem,
      :path => File.join(Rails.root.to_s, "public/video_transcoded/:class/:attachment/:id/:style/:basename.:extension"),
      :default_url => ":class/:attachment/:style/missing.png"
    }

    # Classes auxiliares para Search
    config.autoload_paths << "#{config.root}/app/models/search"

    # Usado pelo simple-navigation (renderer customizado)
    config.autoload_paths << "#{config.root}/app/navigation_renderers"
    config.autoload_paths << "#{config.root}/app/navigations" # arquivos de navegação dinâmica

    # Autoloads code in lib
    config.autoload_paths << "#{config.root}/lib"
    config.autoload_paths << "#{config.root}/lib/vis"

    # Observers têm direito a um lar
    config.autoload_paths << "#{config.root}/app/observers"
    config.autoload_paths << "#{config.root}/app/observers/vis"
    config.autoload_paths << "#{config.root}/app/observers/search"

    # Doorkeepers definem eventos que serão propagados no message bus
    config.autoload_paths << "#{config.root}/app/doorkeepers"

    # Validators customizados
    config.autoload_paths << "#{config.root}/app/validators"

    # Service objects
    config.autoload_paths << "#{config.root}/app/services"

    # Representers
    config.autoload_paths << "#{config.root}/app/representers/**/*"

    # Enumerators
    config.autoload_paths << "#{config.root}/app/enums"

    # Adapters
    config.autoload_paths << "#{config.root}/app/adapters"

    #ckeditor
    config.autoload_paths += %w(#{config.root}/app/models/ckeditor)

    # Observers
    unless File.basename($0) == 'rake'
      config.active_record.observers = [:course_observer,
                                        :space_observer,
                                        :subject_observer,
                                        :lecture_observer,
                                        :user_observer,
                                        :friendship_observer,
                                        :status_observer,
                                        :education_observer,
                                        :experience_observer,
                                        :log_observer,
                                        :user_course_association_observer,
                                        :user_walledgarden_apps_observer,
                                        :user_environment_association_cache_observer,
                                        :friendship_cache_observer,
                                        :user_cache_observer,
                                        :user_course_association_cache_observer,
                                        :course_cache_observer,
                                        :message_cache_observer,
                                        :lecture_cache_observer,
                                        :asset_report_cache_observer,
                                        :solr_profile_indexer_observer,
                                        :solr_education_indexer_observer,
                                        :solr_hierarchy_indexer_observer,
                                        :vis_status_observer,
                                        :vis_lecture_observer,
                                        :vis_result_observer,
                                        :seminar_observer,
      ]
    end

    # Redu logger
    config.overview_logger = YAML.load_file("#{Rails.root}/config/logs.yml")
    config.overview_logger = config.overview_logger['config']

    #Oauth
    config.middleware.use OAuth::Rack::OAuthFilter

    # Seta as exceções da aplicação
    config.exceptions_app = self.routes

    config.vis_data_authentication = {
      :password => ENV['VIS_PASS'],
      :username => ENV['VIS_USER']
    }

    config.redu_services = {}
    config.redu_services[:apps] = {
      :url => "#{ENV['APPS_PAGE']}"
    }
    config.redu_services[:help_center] = {
      :url => "#{ENV['HELP_PAGE']}"
    }
    config.redu_services[:dev] = {
      :url => "#{ENV['DEVS_PAGE']}"
    }
    config.redu_services[:blog] = {
      :url => "#{ENV['PROM_PAGE']}"
    }

    # Configurações de VisClient
    config.vis_client = {
      :url => ENV['VIS_HOST'] + "/hierarchy_notifications.json",
      :host => ENV['VIS_HOST']
    }

    config.vis = {
      :subject_activities => ENV['VIS_HOST'] + "/subjects/activities.json",
      :lecture_participation => ENV['VIS_HOST'] + "/lectures/participation.json",
      :students_participation =>  ENV['VIS_HOST'] + "/user_spaces/participation.json"
    }

    # Configuração da aplicação em omniauth providers
    config.omniauth = {
      :facebook => {
        :app_id => ENV['FACEBOOK_APP_ID'],
        :app_secret => ENV['FACEBOOK_APP_SECRET'],
        :scope => 'public_profile, email',
        :info_fields => 'email,first_name,last_name'
      }
    }

    # SMTP settings
    # config.action_mailer.smtp_settings = {
    #   address: ENV['SMTP_ADDR'],
    #   port: 465,
    #   domain: ENV['SMTP_DOMAIN'],
    #   authentication: "plain",
    #   enable_starttls_auto: true,
    #   user_name: ENV['SMTP_USER'],
    #   password: ENV['SMTP_PASSWD'],
    #   openssl_verify_mode: "none"
    # }
    config.action_mailer.delivery_method = :test
    config.action_mailer.perform_deliveries = false
    config.action_mailer.raise_delivery_errors = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.load_path += Dir[ Rails.root.join("lang", "ui", '*.{rb,yml}').to_s ]

    # Seta locale defaul para pt-br
    config.i18n.default_locale = :"pt-BR"
    I18n.available_locales = [config.i18n.default_locale]
    I18n.locale = config.i18n.default_locale


    # Quantidade de resultados da busca exibidos por páginas
    config.search_results_per_page = 10
    config.search_preview_results_per_page = 4
    config.instant_search_results_per_page = 6
    config.instant_search_preview_results_per_page = 2

    config.assets.enabled = true

    # Layout com bootstrap
    config.assets.precompile += %w(new_application.js friend-invitation.js basic.js landing.js mobile.js status_show.js chat.js chat.jquery.js gamefication_notify.js document.js)
    config.assets.precompile += %w(bootstrap-redu.min.css new_application.css basic.css mobile.css authoring-page.css chat.scss chat.css)
    config.assets.precompile += %w(maintenance.css)

    # Layout sem bootstrap
    config.assets.precompile += %w(ie.js jquery.maskedinput.js canvas.js chart.js webview.js clean.js new_wall.js new_wall/lecture-toggle-comment-or-help.js)
    config.assets.precompile += %w(ie.css icons.redu.css preview-course-old.css page.css cold.css clean.css print.css email.css new_wall.css)

    # Assets da nova landing page
    config.assets.precompile += %w(landing.css jquery.js rails.js)

    # Assets do ckeditor
    config.assets.precompile += %w(ckeditor/*)
  end
end
