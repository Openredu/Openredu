# -*- encoding : utf-8 -*-
namespace :bootstrap do

  desc "Insert audiences"
  task :audiences => :environment do
    Audience.create(:name => "Ensino Superior")
    Audience.create(:name => "Ensino Médio")
    Audience.create(:name => "Ensino Fundamental")
    Audience.create(:name => "Pesquisa")
    Audience.create(:name => "Empresas")
    Audience.create(:name => "Concursos")
    Audience.create(:name => "Pré-Vestibular")
    Audience.create(:name => "Certificações")
    Audience.create(:name => "Diversos")
  end

  desc "Inser standard partner"
  task :partner => :environment do
    Partner.create(:name => "CNS",
                   :email => "cns@redu.com.br",
                   :cnpj => "12.123.123/1234-12",
                   :address => "Beaker street")
  end

  desc "Create OAuth Client Application for ReduVis"
  task :reduvis_app => :environment do
    user_admin = User.find_by_id(2)

    ClientApplication.create(:name => "ReduVis",
                             :url => "http://www.redu.com.br",
                             :user => user_admin,
                             :walledgarden => true)
  end

  desc "Create OAuth Client Application for Redu Apps"
  task :reduapps_app => :environment do
    user_admin = User.find_by_login("administrator")
    test_user = User.find_by_login("test_user")

    c = ClientApplication.create(:name => "Portal de aplicativos",
                             :url => "http://aplicativos.redu.com.br",
                             :user => user_admin,
                             :walledgarden => true)
    c.update_attribute(:secret, 'xxx')

    [user_admin, test_user].each do |u|
      Oauth2Token.create(:client_application => c, :user => u)
    end
  end

  desc "Run all bootstrapping tasks"
  task :all => [:audiences,
                :partner, :reduvis_app, :reduapps_app]
end
