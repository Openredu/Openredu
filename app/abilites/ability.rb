# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  # Regras de authorization
  def initialize(user)
    # Aliases para acoes não padrão
    # Overall Manage
    alias_action :publish, :unpublish, :admin_members,
      :search_users_admin, :destroy_members, :to => :manage

    # Overall Read
    alias_action :rate, :to => :read

    # Environment
    alias_action :admin_courses, :to => :manage

    # Course
    alias_action :admin_spaces, :admin_members_request,
      :moderate_members_requests, :invite_members, :admin_manage_invitations,
      :admin_invitations, :destroy_invitations, :teacher_participation_report,
      :to => :manage
    alias_action :unjoin, :to => :read

    # Space
    alias_action :admin_subjects, :subject_participation_report,
      :lecture_participation_report, :students_participation_report,
      :students_participation_report_show, :to => :manage

    #TODO action manage gerando recursividade
    alias_action :mural, :students_endless, :to => :read

    # Folder
    alias_action :do_the_upload, :upload, :rename,
      :destroy_folder, :destroy_file, :to => :manage
    alias_action :download, :to => :read

    # User
    alias_action :show_mural, :contacts_endless, :environments_endless, :to => :read

    alias_action :edit_account,
      :update_account, :edit_pro_details, :invite, :activate, :deactivate,
      :account, :home, :my_wall, :to => :manage

    # Invitation
    alias_action :resend_email, :destroy, :destroy_invitations, :to => :manage

    # Lecture
    alias_action :rate, :done, :page_content, :to => :read

    # Message
    alias_action :delete_selected, :to => :manage

    # Plan
    alias_action :confirm, :address, :pay, :to => :manage

    # Reports
    alias_action :teacher_participation_interaction, :to => :manage

    # Todos podem criar usuários
    can :create, User

    # Usuários logados podem
    unless user.nil?
      is_admin = user.admin?

      # Ter acesso ao 'Ensine', só usuários logados
      can :teach_index, :base

      # Autorizar apps OAuth
      can :authorize_oauth, :base

      #Autorizar mandar mensage que está online
      can :online, :chats
      can :send_message, User do |friend|
        user.friends? friend
      end

      # Somente donos do aplicativo podem gerencia-lo
      can :manage, ClientApplication, :user_id => user.id

      # Gerencial
      can :manage, :all do |object|
        user.can_manage? object
      end

      # Usuário normal
      can :read, :all do |object|
        user.can_read? object
      end

      unless is_admin
        # Nenhum ambiente bloqueado pode ser visto, a não ser pelo redu_admin
        cannot [:manage, :read], [Environment, Course, Space, Subject, Lecture],
          :blocked => true
      end

      can :create, Environment

      # Course
      can :join, Course

      can :teach, Course do |course|
        user.teacher?(course)
      end

      can [:accept, :deny], Course do |course|
        assoc = user.get_association_with(course)
        !assoc.nil? and assoc.state == "invited"
      end

      # User
      can :read, User
      can :view_mural, User do |u|
        u.settings.view_mural.public? or
        (u.settings.view_mural.friends? && u.friends?(user))
      end

      # Space
      # Necessário para visualizar os usuários do Space
      can :preview, Space do |space|
        user.can_read? space
      end

      # Seminar
      can :upload_multimedia, Seminar do |seminar|
        seminar.can_upload_multimedia?(seminar.lecture)
      end

      # Document
      can :upload_document, Document do |document|
        document.can_upload_document?(document.lecture)
      end


      can :multiauth, User

      # My file
      cannot :upload_file, Folder do |folder|
        !folder.can_upload_file?
      end

      # Join in a Course
      can :add_entry, Course do |el|
        el.can_add_entry?
      end

      # Plan (payment gateway)
      can :read, :success

      # Caso seja o Status de usuário, apenas ele mesmo ou seus amigos
      # podem criá-lo/respondê-lo.
      can [:create, :respond], [Status, Activity, Answer, Help] do |status|
        # Caso seja no mural de um usuário
        ((status.statusable.class.to_s.eql? 'User') && \
         ((can? :manage, status.statusable) ||
          (can? :view_mural, status.statusable))) ||
          # Caso geral (Spaces, Subjects, etc.)
          (user.has_access_to? status.statusable)
      end

      # Result
      can :update, Result, :state => 'started', :user_id => user.id

      # Plan
      cannot :migrate, Plan do |plan|
        (plan.blocked? || plan.migrated?) && !is_admin
      end

      cannot :update, Lecture do |lecture|
        lec = lecture.lectureable

        (lec.is_a?(Seminar) || lec.is_a?(Document) || lec.is_a?(Api::Canvas) \
         || (lec.is_a?(Exercise) && lec.has_results?)) \
         && (can? :manage, lecture)
      end

      # Canvas
      can :read, Api::Canvas do |canvas|
        if canvas.lecture
          can?(:read, canvas.lecture)
        elsif canvas.container
          can?(:read, canvas.container)
        else
          false
        end
      end
      cannot :read, Api::Canvas do |canvas|
        if canvas.lecture
          cannot?(:read, canvas.lecture)
        elsif canvas.container
          cannot?(:read, canvas.container)
        else
          true
        end
      end

      # Busca
      can :search, :all
    end

    # Todos podem ver o preview
    can :preview, [Course, Environment]
    can :preview, Subject, :visible => true
  end
end
