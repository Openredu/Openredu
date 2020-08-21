# -*- encoding : utf-8 -*-
module Api
  class Ability
    include CanCan::Ability
    include Api::EnvironmentAbility
    include Api::CourseAbility
    include Api::CourseEnrollmentAbility
    include Api::SpaceAbility
    include Api::UserAbility
    include Api::LectureAbility
    include Api::SubjectAbility
    include Api::FolderAbility
    include Api::MyfileAbility
    include Api::AssetReportAbility
    include Api::FriendshipAbility

    include Api::ActivityAbility
    include Api::LogAbility
    include Api::HelpAbility
    include Api::AnswerAbility
    include Api::CompoundLogAbility

    def initialize(user)
      can :read, :error
      # Administrador do Openredu
      can :manage, :all if user.try(:role) == Role[:admin]
      can :create_via_api if user.try(:role) == Role[:admin]
      execute_rules(user)
    end

    protected

    def execute_rules(user)
      methods.select { |m| m =~ /.+_abilities$/ }.each do |m|
        send(m, user)
      end
    end
  end
end
