# -*- encoding : utf-8 -*-
Rails.application.config.middleware.use OmniAuth::Builder do
  Redu::Application.config.omniauth.each do |service, app_info|
    provider service, app_info[:app_id], app_info[:app_secret], :scope => 'email', :display => 'popup'
  end
end
