# -*- encoding : utf-8 -*-
module UsersNavigation
  def users_navigation(sidebar)
    # Caso alguma view que não tenha uma relação direta com usuário
    # utilize esta navegação (por utilizar o sidebar da home)
    @user = current_user unless @user

    sidebar.dom_class = 'local-nav'
    sidebar.selected_class = 'ui-state-active'

    sidebar.item :overview, 'Visão Geral', home_user_path(current_user),
      :link => { :class => 'icon-home_16_18-before' }
    sidebar.item :wall, 'Meu Mural', my_wall_user_path(current_user),
      :link => { :class => 'icon-wall_16_18-before' }

    sidebar.item :messages, 'Mensagens', user_messages_path(current_user),
      :link => { :class => 'icon-message_16_18-before'} do |messages_env|
      # Abas
      messages_env.dom_class = 'clearfix ui-tabs-nav'
      messages_env.item :received, 'Recebidas', user_messages_path(@user),
        :highlights_on => Proc.new {
          action_matcher({'messages' => ['index', 'show']}).call &&
          (action_matcher({'messages' => ['show']}).call ?
          @message.sender != @user : true) },
        :class => 'ui-state-default',
        :link => { :class => 'icon-message_16_18-before'},
        :details => { :text => 'visualização', :class => 'details',
                      :if => Proc.new { action_matcher({'messages' => ['show']}).call &&
                                        @message.sender != @user } }
      messages_env.item :sent, 'Enviadas', index_sent_user_messages_path(@user),
        :highlights_on => Proc.new {
          action_matcher({'messages' => ['index_sent', 'show']}).call &&
          (action_matcher({'messages' => ['show']}).call ?
          @message.sender == @user : true) },
        :class => 'ui-state-default',
        :link => { :class => 'icon-answer_message_16_18-before' },
        :details => { :text => 'visualização', :class => 'details',
                      :if => Proc.new { action_matcher({'messages' => ['show']}).call &&
                                        @message.sender == @user } }
      messages_env.item :new, "Nova", new_user_message_path(@user),
        :highlights_on => create_action_matcher('messages'),
        :class => 'ui-state-default',
        :link => { :class => 'icon-add_message_16_18-before' }
    end
    sidebar.item :environments, 'Ambientes', user_environments_path(@user),
      :link => { :class => 'icon-environment_16_18-before' }

    sidebar.item :configurations, 'Configurações',
      edit_user_path(current_user),
      :link => { :class => 'icon-manage_16_18-before' } do |config_nav|
      # Abas
      config_nav.dom_class = 'clearfix ui-tabs-nav'
      config_nav.item :edit, 'Perfil', edit_user_path(@user),
        :highlights_on => update_action_matcher('users'),
        :class => 'ui-state-default',
        :link => { :class => "icon-profile_16_18-before"} do |edit_nav|
        # Sub abas
        edit_nav.dom_class = 'clearfix ui-tabs-nav'
        edit_nav.item :biography, "Biografia", edit_user_path(@user),
          :highlights_on => update_action_matcher('users'),
          :class => 'ui-state-default',
          :link => { :class => 'icon-bio_16_18-before' }
        edit_nav.item :curriculum, "Currículo", curriculum_user_path(@user),
          :class => 'ui-state-default',
          :link => { :class => 'icon-cv_16_18-before' }
      end
      config_nav.item :account, 'Conta', account_user_path(@user),
        :highlights_on => action_matcher({'users' => ['account', 'update_account']}),
        :class => 'ui-state-default',
        :link => { :class => 'icon-account_16_18-before' }
    end
    sidebar.item :contacts, 'Meus Contatos', user_friendships_path(current_user),
      :link => { :class => 'icon-contacts_16_18-before' } do |tab|
      # Aba
      tab.item :invite_friends, 'Convide seus amigos', new_user_friendship_path(@user)
    end
  end
end
