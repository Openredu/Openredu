# -*- encoding : utf-8 -*-
module NewUsersNavigation
  def new_users_navigation(sidebar)
    sidebar.dom_class = 'nav-local'
    sidebar.selected_class = 'nav-local-item-active icon-arrow-right-nav-local-lightblue_11_32-after'

    sidebar.item :overview, 'Visão Geral', home_user_path(@user),
      :class => 'icon-home_16_18-before nav-local-item',
      :link => { :class => 'nav-local-link link-target', :title => 'Visão Geral' }
    sidebar.item :my_wall, 'Meu Mural', my_wall_user_path(@user),
      :class => 'icon-wall_16_18-before nav-local-item',
      :link => { :class => 'nav-local-link link-target', :title => 'Meu Mural' }
    sidebar.item :messages, 'Mensagens', user_messages_path(@user),
      :class => 'icon-message_16_18-before nav-local-item',
      :link => { :class => 'nav-local-link link-target badge-messages', :title => 'Mensagens', :'data-badge' => @user.unread_message_count} do |messages_tab|
      # Abas
      messages_tab.dom_class = 'tabs'
      messages_tab.selected_class = 'tab-active'
      messages_tab.item :received, 'Recebidas', user_messages_path(@user),
        :highlights_on => Proc.new {
          action_matcher({'messages' => ['index', 'show']}).call &&
          (action_matcher({'messages' => ['show']}).call ?
          @message.sender != @user : true) },
        :class => 'tab',
        :link => { :class => 'tab-title icon-message_16_18-before',
                   :title => 'Recebidas' },
                   :details => { :text => 'Visualização', :class => 'tab-sub-title legend',
                                 :if => Proc.new { action_matcher({'messages' => ['show']}).
                                                   call && @message.sender != @user } }
      messages_tab.item :sent, 'Enviadas', index_sent_user_messages_path(@user),
        :highlights_on => Proc.new {
          action_matcher({'messages' => ['index_sent', 'show']}).call &&
          (action_matcher({'messages' => ['show']}).call ?
          @message.sender == @user : true) },
        :class => 'tab',
        :link => { :class => 'tab-title icon-message-sent_16_18-before',
                   :title => 'Enviadas' },
        :details => { :text => 'Visualização', :class => 'tab-sub-title legend',
                      :if => Proc.new { action_matcher({'messages' => ['show']}).
                                        call && @message.sender == @user } }
    end
    sidebar.item :environments, 'Ambientes', user_environments_path(@user),
      :class => 'icon-environment_16_18-before nav-local-item',
      :link => { :class => 'nav-local-link link-target', :title => 'Ambientes' }
    sidebar.item :settings, 'Configurações', edit_user_path(@user),
      :class => 'icon-manage_16_18-before nav-local-item',
      :link => { :class => 'nav-local-link link-target', :title => 'Configurações' } do |settings_tab|
      # Abas
      settings_tab.dom_class = 'tabs'
      settings_tab.selected_class = 'tab-active'
      settings_tab.item :edit, 'Perfil', edit_user_path(@user),
        :highlights_on => update_action_matcher('users'),
        :class => 'tab',
        :link => { :class => 'tab-title icon-profile_16_18-before',
                   :title => 'Perfil' } do |profile_subtab|
        # Sub abas
        profile_subtab.dom_class = 'tab-buttons'
        profile_subtab.selected_class = 'tab-button-active'
        profile_subtab.item :biography, "Biografia", edit_user_path(@user),
          :highlights_on => update_action_matcher('users'),
          :class => 'tab-button icon-biography_16_18-before',
          :title => 'Biografia'
        profile_subtab.item :curriculum, "Currículo", curriculum_user_path(@user),
          :class => 'tab-button icon-curriculum_16_18-before',
          :title => 'Currículo'
      end
      settings_tab.item :account, 'Conta', account_user_path(@user),
        :highlights_on => action_matcher({'users' => ['account', 'update_account']}),
        :class => 'tab',
        :link => { :class => 'tab-title icon-account_16_18-before',
                   :title => 'Conta' }
    end
    sidebar.item :oauth_clients, 'Aplicativos', new_user_oauth_client_path(@user),
      :class => 'nav-local-item icon-app-lightblue_16_18-before ',
      :link => { :class => 'nav-local-link link-target', :title => 'Aplicativos' } do |apps_tab|
      # Abas
      apps_tab.dom_class = 'tabs'
      apps_tab.selected_class = 'tab-active'
      apps_tab.item :new_app, 'Novo Aplicativo', new_user_oauth_client_path(@user), :class => 'tab',
        :highlights_on => create_action_matcher('oauth_clients'),
        :link => { :class => 'tab-title tab-title-without-icon', :title => 'Novo Aplicativo' }
      apps_tab.item :my_apps, 'Meus Aplicativos', user_oauth_clients_path(@user), :class => 'tab',
        :highlights_on => action_matcher({ 'oauth_clients' => ['show', 'index', 'edit', 'update'] }),
        :link => { :class => 'tab-title tab-title-without-icon', :title => 'Meus Aplicativos' } do |apps_subtab|
        # Sub abas
        apps_subtab.dom_class = 'tab-buttons'
        apps_subtab.selected_class = 'tab-button-active'
        if @client_application && !@client_application.new_record?
          apps_subtab.item :about, "Sobre", user_oauth_client_path(@user, @client_application),
            :highlights_on => action_matcher({ 'oauth_clients' => 'show' }),
            :class => 'tab-button tab-button-without-icon', :title => 'Sobre'
          apps_subtab.item :edit, "Editar", edit_user_oauth_client_path(@user, @client_application),
            :highlights_on => update_action_matcher('oauth_clients'),
            :class => 'tab-button tab-button-without-icon', :title => 'Editar'
        end
      end
    end
    sidebar.item :my_contacts, 'Meus Contatos', user_friendships_path(@user),
      :class => 'icon-contacts_16_18-before nav-local-item',
      :link => { :class => 'nav-local-link link-target', :title => 'Meus Contatos' } do |contacts_tab|
      # Abas
      contacts_tab.dom_class = 'tabs'
      contacts_tab.selected_class = 'tab-active'
      contacts_tab.item :friends, 'Amigos', user_friendships_path(@user),
        :highlights_on => Proc.new { action_matcher({'friendships' => ['index', 'new']}).call },
        :class => 'tab',
        :link => { :class => 'tab-title icon-contacts-lightblue_16_18-before', :title => 'Amigos' }
    end
  end
end
