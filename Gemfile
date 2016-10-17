source 'https://rubygems.org'

ruby "1.9.3"

gem 'aasm'
gem 'premailer-rails'
gem 'classy_enum'
gem 'activerecord-import'
gem 'acts_as_tree', '~> 0.1.1'
gem 'acts-as-taggable-on', git: 'git://github.com/mbleigh/acts-as-taggable-on.git'
gem 'ajaxful_rating',
  git: 'git://github.com/edgarjs/ajaxful-rating.git',
  branch: 'rails3'
gem 'authlogic'
gem 'awesome_nested_fields'
gem 'aws-s3', require: 'aws/s3'
gem 'aws-sdk'
gem 'bundler', '~> 1.2'
gem 'cancan', '~> 1.6.7'
gem 'ckeditor', '3.4.2.pre'
gem 'daemons', '1.0.10'
gem 'date_validator'
gem 'deep_cloneable'
gem 'delayed_job_mongoid'
gem 'bson_ext'
gem 'dynamic_form'
gem 'em-http-request'
gem 'eventmachine'
gem 'exceptional'
gem 'factory_girl_rails'
gem "redu-has_friends", "~> 1.0", require: "has_friends"
gem 'invitable', git: 'git://github.com/OpenRedu/invitable.git'
gem 'jquery-rails', '>= 1.0.12'
gem 'kaminari', git: 'git://github.com/amatsuda/kaminari.git'
gem 'mime-types'
gem "mysql2"
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'pusher'
gem 'pagseguro', '~> 0.1.10'
gem 'paperclip', '~> 2.7.5'
gem 'rails', '~> 3.2.13'
gem "rake", "~> 10.0.4"
gem 'remotipart', '~> 1.0'
gem 'scribd_fu', git: 'git://github.com/guiocavalcanti/scribd_fu.git',
  branch: 'without-scape'
gem 'simple-navigation', git: 'git://github.com/andi/simple-navigation.git'
gem 'sunspot_rails'
gem 'route_translator'
gem 'useragent'
gem 'vis_client', git: 'git://github.com/redu/vis_client.git',
  branch: 'ruby-1-9-3'
gem 'chronic' # Necessário ao whenever
gem 'whenever', require: false
gem 'zencoder'
gem 'untied-publisher', '~> 0.0.7.pre3'
gem 'yajl-ruby'
gem 'simple_acts_as_list'
gem 'ey_config'
gem 'destroy_soon'
gem 'redu_analytics', git: 'git://github.com/redu/analytics.git'
gem 'humanizer'
gem 'valium'
gem 'dalli'
gem 'simple-private-messages', '0.0.0', # A gem não possui .gemspec
  git: 'git://github.com/jongilbraith/simple-private-messages.git'
gem 'rails_autolink'
gem 'rubyzip', require: 'zip/zip'
gem 'truncate_html'

# Gems específicos para a API
gem 'oauth-plugin', '~> 0.4.0'
gem 'rack-cors', require: 'rack/cors'
gem 'roar-rails'

group :assets do
  gem 'sass-rails',   '~> 3.2'
  gem 'compass-rails'
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '~> 2'
  gem 'asset_sync'
  gem 'turbo-sprockets-rails3'
end

# Gems específicos de algum ambiente
group :development, :test do
  gem 'jasmine'
  gem 'no_peeping_toms', git: 'git://github.com/patmaddox/no-peeping-toms.git'
  gem 'rails3-generators'
  gem "rspec-rails", "~> 2.13"
  gem 'sunspot_solr'
end

group :test do
  gem 'shoulda-matchers', "~> 1"
  gem 'webmock'
  gem 'ruby-prof'
end

group :development do
  # gem 'uniform_notifier'

  # Gems úteis p/ análise performance
  # gem 'bullet'
  # gem 'rack-mini-profiler', '0.1.10'
  # gem 'rails-footnotes', '>= 3.7.5.rc4'
end

group :production do
  gem 'newrelic_rpm'
end

group :debug do
  gem 'debugger'
end
