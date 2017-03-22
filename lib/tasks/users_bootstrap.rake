# -*- encoding : utf-8 -*-
namespace :bootstrap do

  desc "Insert test administrator"
  task :default_admin => :environment do
    User.reset_callbacks(:save)
    User.reset_callbacks(:create)
    theadmin = User.new(:login => 'administrator',
                        :email => 'redu@redu.com.br',
                        :password => 'reduadmin123',
                        :password_confirmation => 'reduadmin123',
                        :birthday => 20.years.ago,
                        :first_name => 'Admin',
                        :last_name => 'Redu',
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
                       :password => 'redutest123',
                       :password_confirmation => 'redutest123',
                       :birthday => 20.years.ago,
                       :first_name => 'Test',
                       :activated_at => Time.now,
                       :last_login_at => Time.now,
                       :last_name => 'User',
                       :role => Role[:member])
    theuser.save
    theuser.create_settings!
  end

  desc "Run all bootstrapping tasks"
  task :all => [:default_user, :default_admin]
end
