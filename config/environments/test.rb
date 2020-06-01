# -*- encoding : utf-8 -*-
Redu::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Nome e URL do app
  config.url = "localhost:3000"

  config.action_mailer.default_url_options = { :host => config.url }

  # Armazena no sist. de arquivos
  config.paperclip = {
    :path => File.join(Rails.root.to_s, "public/:class/:attachment/:id/:style/:basename.:extension"),
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
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

  # Ativa o modo de testes do OmniAuth
  OmniAuth.config.test_mode = true

  # Configura o mockup do OmniAuth
  OmniAuth.config.mock_auth[:some_provider] = {
    :provider => 'some-provider',
    :uid => '123545',
    :info => {:email => 'user@example.com',
      :first_name => 'Some',
      :last_name => 'Userville'
    }
  }

  # Configurações de VisClient
  config.vis_client = {
   :url => "http://localhost:4000/hierarchy_notifications.json",
   :host => "http://localhost:4000",
   :migration => "http://localhost:4000/database_hierarchy_notifications.json"
  }

  config.vis = {
    :subject_activities => "http://localhost:4000/subjects/activities.json",
    :lecture_participation => "http://localhost:4000/lectures/participation.json",
    :students_participation => "http://localhost:4000/user_spaces/participation.json"
  }

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  #enable captcha
  config.enable_humanizer = false
end
