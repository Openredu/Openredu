# -*- encoding : utf-8 -*-
# Módulo para renderização dinâmica das navegações.
#
# Aqui o contexto no qual a navegação será renderizada é
# definido em tempo de execução removendo qualquer lógica dos controllers.
# Os módulos específicos para cada navegação são incluídos no começo deste módulo.
# Qualquer modificação na navegação global é feita neste arquivo, assim como
# que área estará ativada, usando o método 'global_highlighted'.
module NavigationHelper
  include UsersNavigation
  include UserProfileNavigation
  include EnvironmentsAdminNavigation
  include EnvironmentsNavigation
  include CoursesAdminNavigation
  include CoursesNavigation
  include SpacesAdminNavigation
  include SpacesNavigation
  include NewUsersNavigation
  include SearchNavigation

  # Renderiza navegação global
  def render_dynamic_navigation(opts = { :level => 1, :renderer => :list })
    # O método da navegação é o nome do contexto + "_navigation" always
    navigation_method = opts[:context].to_s + "_navigation"

    render_navigation(:level => opts[:level], :renderer => opts[:renderer]) do |primary|
      primary.dom_class = 'nav-global-buttons'
      primary.selected_class = 'nav-global-button-active'

      # Os itens ficam ativados de acordo com a função global_highlighted
      # Os métodos são renderizados de acordo com seu contexto
      #   Se o contexto for :global só renderiza a navegação global
      #   Se for outro contexto este será renderizado dentro do item que está ativado
      primary.item :start, 'Início',
        current_user ? home_user_path(current_user) : application_path,
        :title => 'Início', :class => 'nav-global-button',
        :highlights_on => lambda{ global_highlighted == :start } do |sidebar|
          unless opts[:context] == :global
            method(navigation_method).call(sidebar) if active_navigation_item_key(:level => 1) != :environments
          end
        end
      primary.item :teach, 'Ensine', teach_index_path,
        :title => 'Ensine', :class => 'nav-global-button'
      primary.item :environments, 'Ambientes', environments_index_path,
        :title => 'Ambientes', :class => 'nav-global-button',
        :highlights_on => lambda{ global_highlighted == :environments } do |sidebar|
          unless opts[:context] == :global
            method(navigation_method).call(sidebar) if active_navigation_item_key(:level => 1) == :environments
          end
        end
      primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url],
        :title => 'Aplicativos', :class => 'nav-global-button'
    end
  end

  # Define item ativo na navegação global
  def global_highlighted
    # Início só é selecionado se estiver relacionado ao current user
    if !request.fullpath.match(%r(\A#{ users_path }/#{ current_user.to_param })).nil?
      :start
    # Não aciona a navegacão global se estiver na área relacionada a
    # profile de outro usuário, busca ou páginas estáticas
    elsif !request.fullpath.match(%r(\A#{ search_path })).nil? ||
          (params[:controller] == "pages") ||
          !request.fullpath.match(%r(\A#{ users_path }/)).nil?
      :global
    elsif !request.fullpath.match(%r(\A#{ environments_path }[?])).nil? ||
          !request.fullpath.match(%r(\A#{ teach_index_path })).nil?
      :teach
    else
      :environments
    end
  end

  # Renderiza um item do tipo canvas na navegação local.
  def render_local_nav_canvas(canvas)
    content = content_tag(:span, canvas.current_name,
                          :title => canvas.current_name,
                          :class => "local-nav-item-canvas text-truncate")
    content << content_tag(:span, "por: #{canvas.user.display_name}",
                           :title => canvas.user.display_name,
                           :class => "local-nav-item-canvas-author text-truncate")
  end
end
