# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'oauth/rack/oauth_filter'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test production))
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

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.load_path += Dir[ Rails.root.join("lang", "ui", '*.{rb,yml}').to_s ]
    config.i18n.default_locale = "pt-BR"

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

    # S3 credentials
    if File.exists?("#{Rails.root}/config/s3.yml")
      config.s3_config = YAML.load_file("#{Rails.root}/config/s3.yml")
      config.s3_credentials = config.s3_config[Rails.env]
    end

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
    config.name = "Redu"
    config.tagline = "Rede Social Educacional"
    config.description = "Rede Social Educacional"
    config.email = "contato@redu.com.br"

    # Paginação
    config.items_per_page = 10

    # Máximo de caracteres p/ descrição
    config.desc_char_limit = 200

    config.session_store = :active_record_store
    config.representer.default_url_options = {:host => "127.0.0.1:3000"}

    # ActionMailer
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :test

    config.paperclip = {
      :storage => :s3,
      :s3_credentials => config.s3_credentials,
      :bucket => config.s3_credentials['bucket'], # redu-uploads
      :path => ":class/:attachment/:id/:style/:basename.:extension",
      :default_url => "http://#{config.s3_credentials['assets_bucket']}.s3.amazonaws.com/images/new/missing_:class_:style.png",
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
      :bucket => config.s3_credentials['files_bucket'], # redu-files
      :path => ":class/:attachment/:id/:style/:basename.:extension",
      :default_url => ":class/:attachment/:style/missing.png",
      :styles => {}
    })

    # Configurações de conversão e storage de videos (Seminar)
    config.video_original = { # Arquivo original do video (uploaded)
      :storage => :s3,
      :s3_credentials => config.s3_credentials,
      :bucket => config.s3_credentials['bucket'],
      :path => ":class/:attachment/:id/:style/:basename.:extension",
      :default_url => "http://#{config.s3_credentials['assets_bucket']}.s3.amazonaws.com/images/new/missing_:class_:style.png",
      :styles => {}
    }

    config.video_transcoded = { # Arquivo convertido
      :storage => :s3,
      :s3_credentials => config.s3_credentials,
      :bucket => config.s3_credentials['videos_bucket'],
      :path => ":class/:attachment/:id/:style/:basename.:extension",
      :default_url => "http://#{config.s3_credentials['assets_bucket']}.s3.amazonaws.com/images/new/missing_:class_:style.png",
    }

    # Usado em :controller => jobs, :action => notify
    config.zencoder_credentials = {
      :username => 'zencoder',
      :password => 'MCZC2pDQyt5bzko1'
    }

    # No ambiente de desenvolvimento :test => 1 (definido em development.rb)
    config.zencoder = {
      :api_key => '69c8730bf5c0134af339a97b6a2d53e0',
      :input => '',
      :output => {
        :url => '',
        :video_codec => "vp6",
        :public => 1,
        :thumbnails => {
          :number => 6,
          :size => "160x120",
          :base_url => '',
          :prefix => "thumb"
        },
        :notifications => {
          :format => 'json',
          :url => ''
        }
     }
    }

    # Usado pelo WYSIWYG CKEditor
    config.autoload_paths << "#{config.root}/app/models/ckeditor"

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

    # Configurações do Pusher (redu app)
    config.pusher = {
      :app_id => '4577',
      :key => 'f786a58d885e7397ecaa',
      :secret => '1de7afbc11094fcfa16b'
    }

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
                                        :partner_user_association_cache_observer,
                                        :partner_cache_observer,
                                        :message_cache_observer,
                                        :lecture_cache_observer,
                                        :asset_report_cache_observer,
                                        :chat_message_observer,
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
      :password => "NyugAkSoP",
      :username => "api-team"
    }

    config.redu_services = {}
    config.redu_services[:apps] = {
      :url => "http://aplicativos.redu.com.br"
    }
    config.redu_services[:help_center] = {
      :url => "http://ajuda.redu.com.br/"
    }
    config.redu_services[:dev] = {
      :url => "http://developers.redu.com.br/"
    }
    config.redu_services[:blog] = {
      :url => "http://blog.redu.com.br/"
    }

    # Seta locale defaul para pt-br
    config.i18n.default_locale = :"pt-BR"
    I18n.locale = config.i18n.default_locale
    I18n.available_locales = [config.i18n.default_locale]

    # Quantidade de resultados da busca exibidos por páginas
    config.search_results_per_page = 10
    config.search_preview_results_per_page = 4
    config.instant_search_results_per_page = 6
    config.instant_search_preview_results_per_page = 2

    config.assets.enabled = true

    # Caminho para os assets do CKEditor
    config.assets.ckeditor_path = "#{config.assets.prefix}/ckeditor"

    # Layout com bootstrap
    config.assets.precompile += %w(new_application.js friend-invitation.js basic.js landing.js mobile.js status_show.js)
    config.assets.precompile += %w(bootstrap-redu.min.css new_application.css basic.css mobile.css authoring-page.css)
    config.assets.precompile += %w(maintenance.css)

    # Layout sem bootstrap
    config.assets.precompile += %w(ie.js chat.js outdated_browser.js ckeditor.js olark.js jquery.maskedinput.js canvas.js chart.js jwplayer.js webview.js clean.js new_wall.js new_wall/lecture-toggle-comment-or-help.js)
    config.assets.precompile += %w(ie.css icons.redu.css chat.css outdated_browser.css preview-course-old.css page.css cold.css clean.css print.css email.css new_wall.css)

    # CKEditor
    config.assets.precompile += %w(ckeditor/*)
  end
end
