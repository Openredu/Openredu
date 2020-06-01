# -*- encoding : utf-8 -*-
namespace :bootstrap do

  desc "Insert test administrator"
  task :default_admin => :environment do
    User.reset_callbacks(:save)
    User.reset_callbacks(:create)
    theadmin = User.new(:login => 'administrator',
                        :email => 'openredu@openredu.com.br',
                        :password => 'admin123',
                        :password_confirmation => 'admin123',
                        :birthday => 20.years.ago,
                        :first_name => 'Admin',
                        :last_name => 'Openredu',
                        :activated_at => Time.now,
                        :last_login_at => Time.now,
                        :role => Role[:admin])
    theadmin.role = Role[:admin] # O default é member
    theadmin.save
    theadmin.create_settings!
  end

  desc "Insert test user"
  task :default_user => :environment do
    User.reset_callbacks(:save)
    User.reset_callbacks(:create)
    theuser = User.new(:login => 'test_user',
                       :email => 'test_user@example.com',
                       :password => 'openredutest123',
                       :password_confirmation => 'openredutest123',
                       :birthday => 20.years.ago,
                       :first_name => 'Test',
                       :activated_at => Time.now,
                       :last_login_at => Time.now,
                       :last_name => 'User',
                       :role => Role[:member])
    theuser.save
    theuser.create_settings!
  end

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
  task :all => [:audiences, :default_user, :default_admin, :reduvis_app, :reduapps_app]
end
