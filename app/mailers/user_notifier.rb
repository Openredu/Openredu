# -*- encoding : utf-8 -*-
class UserNotifier < BaseMailer
  # Enviado ao aprovar a participação de um usuário num Course
  def approve_membership(user, course)
    @user = user
    @url = environment_course_url(course.environment, course)
    @course = course

    mail(:to => user.email,
         :subject => "Sua participação no curso \"#{course.name}\" foi aprovada!",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado ao recusar a participcação num Course
  def reject_membership(user, course)
    @user = user
    @course = course

    mail(:to => user.email,
         :subject => "Sua participação no curso \"#{course.name}\" foi negada.",
         :date => Time.now)
  end

  # E-mails de contato enviado para o staff
  def contact_redu(contact)
    @message = contact.body
    @abc = contact.body

    mail(:to => Redu::Application.config.email,
         :subject => "[#{contact.kind}] #{contact.subject}",
         :reply_to => contact.email,
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado para o destinatário da mensagem
  def message_notification(message)
    @user = message.recipient
    @message = message

    mail(:to => @user.email,
         :subject => "[#{Redu::Application.config.name}] #{message.sender.display_name} lhe enviou uma mensagem privada.",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado quando o Plan foi bloqueado
  def blocked_notice(user, plan)
    @user = user
    @plan = plan
    @billable_name = plan.billable.try(:name) || plan.billable_audit.try(:[], "name")

    mail(:to => user.email,
         :subject => "Plano do(a) #{@billable_name} foi bloqueado",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado quando um upgrade de plano é requisitado
  def upgrade_request(user, old_plan, new_plan)
    @user = user
    @old_plan = old_plan
    @new_plan = new_plan

    mail(:to => Redu::Application.config.email,
         :subject => "[upgrade] #{@user.id}",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado quando o Plan foi bloqueado
  def blocked_notice(user, plan)
    @user = user
    @plan = plan
    @billable_name = plan.billable.try(:name) || plan.billable_audit.try(:[], "name")

    mail(:to => user.email,
         :subject => "Plano do(a) #{@billable_name} foi bloqueado",
         :date => Time.now) do |format|
      format.text
    end
  end

  # Enviado ao convidar um usuário para um Course
  def course_invitation(user, course)
    @user, @course = user, course
    @environment = @course.environment

    mail(:to => user.email,
        :subject => "Você foi convidado para realizar um curso a distância",
        :date => Time.now) do |format|
      format.html
    end
  end

  # Enviado ao convidar um usuário não cadastrado para o Redu
  def external_user_course_invitation(user_course_invitation, course)
    @user_course_invitation = user_course_invitation
    @course = course

    mail(:to => user_course_invitation.email,
         :subject => "Você foi convidado para realizar um curso a distância",
         :date => Time.now) do |format|
      format.text
    end

  end

  def subject_added(user, subject)
    @user = user
    @subj = subject
    @environment = subject.space.course.environment
    @course = @subj.space.course

    mail(:subject => "Novo módulo #{@subj.name}", :to => @user.email) do |format|
      format.html
    end
  end

  def space_added(user, space)
    @user, @space, @course = user, space, space.course
    @environment = space.course.environment

    mail(:subject => "Nova disciplina: #{@space.name}",
         :to => @user.email) do |format|
      format.html
    end
  end

  def friendship_invitation(invitation)
    @invitation = invitation
    @email = invitation.email
    user = invitation.user
    uca = user.user_course_associations.approved
    @contacts = { :total => user.friends.count }
    @courses = { :total => user.courses.count,
                 :environment_admin => uca.with_roles([:environment_admin]).count,
                 :tutor => uca.with_roles([:tutor]).count,
                 :teacher => uca.with_roles([:teacher]).count }

    mail(:subject => "Você foi convidado para o #{Redu::Application.config.name}", :to => @email) do |format|
      format.html
    end
  end

  # Enviado para o usuário requisitado numa requisição de conexão
  #
  # friend = User que está recebendo o convite
  # user = User que está enviando o convite
  def friendship_requested(user, friend)
    @user, @friend = user, friend
    uca = @user.user_course_associations.approved

    @contacts = { :total => @user.friends.count,
                  :in_common => @user.friends_in_common_with(@friend).count }
    @courses = { :total => @user.courses.count,
                 :environment_admin => uca.with_roles([:environment_admin]).count,
                 :tutor => uca.with_roles([:tutor]).count,
                 :teacher => uca.with_roles([:teacher]).count }

    mail(:subject => "#{user.display_name} quer se conectar",
         :to => @friend.email) do |format|
      format.html
     end
  end

  # Email de ativação de conta
  def user_signedup(user_id)
    @user = User.find(user_id)

    mail(:to => @user.email,
         :subject => "Ative sua conta") do |format|
      format.html
     end
  end

  # Redefinição de senha
  def user_reseted_password(user)
    @user = user

    mail(:to => user.email,
         :subject => "Redefinição de senha") do |format|
      format.html
    end
  end

  # Confirmação de Redefinição de senha
  def confirm_user_reseted_password(user, new_password)
    @user = user
    @new_password = new_password

    mail(:to => user.email,
         :subject => "Redefinição de senha") do |format|
      format.html
    end
  end

  # Pedido de participação num Course
  def course_moderation_requested(course, admin, user)
    @course, @user = course, user
    @environment = @course.environment

    mail(:to => admin.email,
         :subject => "Moderação pendente em #{@course.name}") do |format|
      format.html
    end

  end
end
