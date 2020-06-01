# -*- encoding : utf-8 -*-
require 'active_support/concern'

module InvitationsProcessor
  extend ActiveSupport::Concern

  # Processa a requisição de convite de amizade (por email e
  # por id do usuário cadastrado no Openredu), seguindo as regras
  # de negócio relacionadas a criação de requisições de amizade.
  #
  # @params => parâmetros da requisição (:friend_id | :emails)
  # @user => remetente do convite
  def process_invites(params, user)
    friend_ids = params['friend_id'].to_s.split(",")
    emails = params['emails'].to_s.split(",")

    friend = process_friendships(friend_ids, user) unless friend_ids.empty?
    process_invitations(emails, user) unless emails.empty?
    return friend
  end

  # Destrói em batch as requisições de amizade selecionadas
  # pelo usuário.
  #
  # @user => Usuário logado, que está gerenciando seus convites
  def batch_destroy_invitations(invitations, user)
    invitations.each{ |i| i.destroy }
  end

  # Destrói em batch as requisições de amizade selecionadas
  # pelo usuário.
  #
  # @user => Usuário logado, que está gerenciando seus convites
  def batch_destroy_friendships(friendship_requests, user)
    friendship_requests.each do |friendship_request|
      friend = friendship_request.friend
      friendship_receive = friend.friendship_for(user)

      friendship_request.destroy
      friendship_receive.destroy
    end
  end

  private
  def process_friendships(friend_ids, user)
    if friend_ids.size > 0
      friend_ids.each do |friend_id|
        friend = User.find(friend_id)
        user.be_friends_with(friend)
        #Retona o 1 friend convidado (no caso de convite único)
      end
      User.find(friend_ids.first)
    end
  end

  def process_invitations(emails, user)
    redu_users_ids = []
    emails.each do |email|
      invitee = User.where(:email => email)
      if invitee.empty?
        Invitation.invite(:user => user, :hostable => user, :email => email) do |invitation|
          UserNotifier.delay(:queue => 'email').friendship_invitation(invitation)
        end
      else
        redu_users_ids << invitee.first.id
      end
    end
    process_friendships(redu_users_ids, user)
  end
end
