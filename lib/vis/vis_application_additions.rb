# -*- encoding : utf-8 -*-
module VisApplicationAdditions
  # Métodos de apoio para a aplicação de visualização do Redu

  module Finder
    extend ActiveSupport::Concern

    def application
      ClientApplication.find(:first, :conditions => { :name => 'ReduVis' })
    end
  end

  module Controller
    extend ActiveSupport::Concern
    include VisApplicationAdditions::Finder

    def vis_application
      @vis_application ||= application
    end

    def current_vis_token
      @current_vis_token ||=
        Oauth2Token.user_token_for(current_user, vis_application)
      @current_vis_token.try(:token)
    end
  end

  module Utils
    extend ActiveSupport::Concern
    include VisApplicationAdditions::Finder

    def create_token_for(user)
      Oauth2Token.create(:client_application => application, :user => user)
    end
  end
end
