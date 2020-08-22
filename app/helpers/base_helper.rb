# -*- encoding : utf-8 -*-

# Methods added to this helper will be available to all templates in the application.
module BaseHelper

  # Cria markup da navegação global a partir da navegação do contexto passado
  # Context default: :global (Só renderiza a navegação global)
  def global_nav(context=:global)
    render_dynamic_navigation(:context => context, :level => 1,
                              :renderer => :links)
  end

  # Cria markup da navegação local a partir da navegação do contexto passado
  def local_nav(context)
    render_dynamic_navigation(:context => context, :level => 2,
                              :renderer => ListSidebar)
  end

  # Cria markup da navegação local a partir da navegação do contexto passado
  def new_local_nav(context)
    render_dynamic_navigation(:context => context, :level => 2,
                              :renderer => NewListSidebar)
  end

  # Cria markup das big abas
  def big_tabs(context, opts={}, &block)
    locals = {
      :navigation => render_dynamic_navigation(:context => context, :level => 3,
                                               :renderer => ListDetailed),
      :options => opts,
      :body => capture(&block)
    }

    render :partial => "shared/big_tabs", :locals => locals
  end

  # Cria markup das abas (compatível com o jQuery UI) a partir da navegação
  # do contexto passado
  def tabs(context, opts={}, &block)
    locals = {
      :navigation => render_dynamic_navigation(:context => context, :level => 3,
                                               :renderer => ListDetailed),
      :options => opts,
      :body => capture(&block)
    }

    render(:partial => 'shared/tabs', :locals => locals)
  end

  # Cria markup das abas a partir da navegação do contexto passado
  def new_tabs(context)
    render_dynamic_navigation(:context => context, :level => 3,
                              :renderer => ListDetailed)
  end

  # Cria markup das sub abas (compatível com jQuery UI) a partir da navegação
  # do contexto passado
  def subtabs(context, opts={}, &block)
    locals = {
      :navigation => render_dynamic_navigation(:context => context, :level => 4),
      :options => opts,
      :body => capture(&block)
    }

    render(:partial => 'shared/subtabs', :locals => locals)
  end

  # Cria markup das sub abas a partir da navegação do contexto passado
  def new_subtabs(context)
    render_dynamic_navigation(:context => context, :level => 4, :renderer => :links)
  end

  def error_for(object, method = nil, options={})
    if method
      err = instance_variable_get("@#{object}").errors[method].to_sentence rescue instance_variable_get("@#{object}").errors[method]
    else
      err = @errors["#{object}"] rescue nil
    end
    options.merge!(:class=>'errorMessageField',:id=>"#{[object,method].compact.join('_')}-error",
    :style=> (err ? "#{options[:style]}":"#{options[:style]};display: none;"))
    content_tag("p", err || "", options )
  end

  # Mostra todos os erros de um determinado atributo em forma de lista
  def concave_errors_for(object, method)
    errors = object.errors[method].collect do |msg|
      content_tag(:li, msg)
    end.join.html_safe

    content_tag(:ul, errors, :class => 'errors_on_field control-errors') unless object.errors.empty?
  end

  def type_class(resource)
    icons = ['3gp', 'bat', 'bmp', 'doc', 'css', 'exe', 'gif', 'jpg', 'jpeg', 'jar','zip',
             'mp3', 'mp4', 'avi', 'mpeg', 'mov', 'm4p', 'ogg', 'pdf', 'png', 'psd', 'ppt', 'txt', 'swf', 'wmv', 'xls', 'xml', 'zip']

    file_ext = resource.attachment_file_name.split('.').last if resource.attachment_file_name.split('.').length > 0
    if file_ext and icons.include? file_ext
      'ext_'+ file_ext
    else
      'ext_blank'
    end
  end

  # Sobrescrito para exibir mensagem de erro apenas com o nome
  # dos campos inválidos.
  def concave_error_messages_for(*params)
    options = params.extract_options!.symbolize_keys

    objects = Array.wrap(options.delete(:object) || params).map do |object|
      object = instance_variable_get("@#{object}") unless object.respond_to?(:to_model)
      object = convert_to_model(object)

      if object.class.respond_to?(:model_name)
        options[:object_name] ||= object.class.model_name.human.downcase
      end

      object
    end

    objects.compact!
    count = objects.inject(0) {|sum, object| sum + object.errors.count }

    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'error_explanation'
        end
      end
      options[:object_name] ||= params.first

      I18n.with_options :locale => options[:locale],
        :scope => [:activerecord, :errors, :template] do |locale|
        header_message = if options.include?(:header_message)
                            options[:header_message]
                         else 
                            locale.t :header, :count => count,
                              :model => options[:object_name].to_s.gsub('_', ' ')
                         end

        message = options.include?(:message) ? options[:message] : locale.t(:body, :count => count)

        error_messages = objects.sum do |object|
          object.errors.collect do |attr, error|
            object.class.human_attribute_name(attr, :default => attr)
          end
        end.uniq.join(", ").html_safe



        contents = ''
        unless header_message.blank?
          contents << content_tag(options[:header_tag] || :h2, header_message)
        end
        contents << content_tag(:p, message) unless message.blank?
        contents << content_tag(:p, error_messages, :class => "invalid_fields")

        content_tag(:div, contents.html_safe, html)
      end
    else
      ''
    end
  end

  # Coloca as mensagens de erro nos elementos de mensagens do sistema do bootstrap.
  def new_concave_error_messages_for(*params)
    options = params.extract_options!.symbolize_keys

    objects = Array.wrap(options.delete(:object) || params).map do |object|
      object = instance_variable_get("@#{object}") unless object.respond_to?(:to_model)
      object = convert_to_model(object)

      if object.class.respond_to?(:model_name)
        options[:object_name] ||= object.class.model_name.human.downcase
      end

      object
    end

    objects.compact!
    count = objects.inject(0) {|sum, object| sum + object.errors.count }

    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'system-message message-warning fade in'
        end
      end
      options[:object_name] ||= params.first

      I18n.with_options :locale => options[:locale],
        :scope => [:activerecord, :errors, :template] do |locale|
        header_message = if options.include?(:header_message)
                            options[:header_message]
                         else
                            locale.t :header, :count => count,
                              :model => options[:object_name].to_s.gsub('_', ' ')
                         end

        message = options.include?(:message) ? options[:message] : locale.t(:body, count: count)

        error_messages = objects.sum do |object|
          object.errors.collect do |attr, error|
            object.class.human_attribute_name(attr, :default => attr)
          end
        end.uniq.join(", ").html_safe



        contents = ''
        contents << content_tag(:span, "×", :class => "message-close", "data-dismiss" => "alert")
        unless message.blank?
          contents << content_tag(:p, content_tag(options[:header_tag] || :strong, header_message) + " " + message)
        end
        contents << content_tag(:p, error_messages, :class => "invalid_fields")

        content_tag(:div, contents.html_safe, html)
      end
    else
      ''
    end
  end

  def truncate_chars(text, length = 30, end_string = '...')
     return if text.blank?
     (text.length > length) ? text[0..length] + end_string  : text
  end

  def page_title
    app_base = Redu::Application.config.name
    tagline = " — #{Redu::Application.config.tagline}"

    title = app_base
    case controller.controller_name
      when 'base'
          title += tagline
                        when 'pages'
                          if @page and @page.title
                            title = @page.title + ' - ' + app_base + tagline
                          end
      when 'posts'
        if @post and @post.title
          title = @post.title + ' - ' + app_base + tagline
          title += (@post.tags.empty? ? '' : " - "+ t(:keywords) +": " + @post.tags[0...4].join(', ') )
          @canonical_url = user_post_url(@post.user, @post)
        end
      when 'users'
        if @user && !@user.new_record? && @user.login
          title = @user.login
          title += ' - ' + app_base + tagline
          @canonical_url = user_url(@user)
        else
          title = t(:showing_users) + ' - ' + app_base + tagline
        end
      when 'photos'
        if @user and @user.login
          title = @user.login + '\'s '+ t(:photos) +' - ' + app_base + tagline
        end
      when 'tags'
        case controller.action_name
          when 'show'
            title = @tags.map(&:name).join(', ') + ' '
            title += params[:type] ? params[:type].pluralize : t(:posts_photos_and_bookmarks)
            title += ' (Related: ' + @related_tags.join(', ') + ')' if @related_tags
            title += ' | ' + app_base
            @canonical_url = tag_url(URI.escape(@tags_raw, /[\/.?#]/)) if @tags_raw
          else
          title = 'Showing tags - ' + app_base + tagline
        end
      when 'categories'
        if @category and @category.name
          title = @category.name + ' '+ t(:posts_photos_and_bookmarks) +' - ' + app_base + tagline
        else
          title = t(:showing_categories) + ' - ' + app_base + tagline
        end
      when 'lectures'
      if @lecture and @lecture.name
        title = 'Aula: ' + @lecture.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Aulas' +' - ' + app_base + tagline
      end
      when 'spaces'
      if @space and @space.name
        title = @space.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Disciplinas' +' - ' + app_base + tagline
      end
      when 'skills'
        if @skill and @skill.name
          title = t(:find_an_expert_in) + ' ' + @skill.name + ' - ' + app_base + tagline
        else
          title = t(:find_experts) + ' - ' + app_base + tagline
        end
      when 'sessions'
        title = t(:login) + ' - ' + app_base + tagline
      when 'environments'
        title = 'Ambientes' + ' - ' + app_base + tagline
      when 'courses'
        title = 'Disciplinas' + ' - ' + app_base + tagline
      when 'leaderboards'
        title = 'Leaderboard do Curso' + ' - ' + app_base + tagline
      when 'global_questions'
        title = 'Banco de Questões' + ' - ' + app_base + tagline
      when 'strong_tags'
        title = 'Lista de Tags' + ' - ' + app_base + tagline
    end

    if @page_title
      title = @page_title + ' - ' + app_base + tagline
    elsif title == app_base
      title = t(:showing) + ' ' + controller.controller_name.capitalize + ' - ' + app_base + tagline
    end
    title.html_safe
  end

  def last_active
    session[:last_active] ||= Time.now.utc
  end

  def submit_tag(value = t( :save_changes ), options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>or " + or_option + "</span>" if or_option
    super
  end

  def get_random_number
    SecureRandom.hex(4)
  end

  # Sidebar esquerdo de user
  def last_accessed_courses(user)
    user.user_course_associations.includes(:course => :environment).
      last_accessed(3)
  end
end

module AsyncJSHelper
  # Carrega asset de forma lazy.
  # Opções:
  #   type: pode ser js (default) ou css
  #   clear: caso o arquivo já tenha sido incluido, tenta remover antes de
  #    adicionar novamente. Default frue
  def lazy_load(package, options = {}, &block)
    opts = {
      :type => :js,
      :clear => true
    }.merge(options)

    package = if opts[:type] == :css
      stylesheet_path(package)
    else
      javascript_path(package)
    end
    package = package.to_a.flatten

    javascript_tag(:type => 'text/javascript') do
      result = ""

      if opts[:clear]
        result << <<-END
          $(document).ready(function(){
            $(document).removeLazyAssets({ paths : #{package.to_json}});
            LazyLoad.#{opts[:type].to_s}(#{package.to_json}
        END
      else
        result << <<-END
          $(document).ready(function(){
            LazyLoad.#{opts[:type].to_s}(#{package.to_json}
        END
      end

      if block.nil?
        result << ");"
      else
        result << ", function(){ #{capture(&block)}});"
      end

      result << <<-END
            });
      END

      result.html_safe
    end.html_safe
  end

  private

  # Retorna um número dentro de parênteses caso ele seja maior que zero.
  def parentize(number)
    result = ""
    if number > 0
      result = "(#{number.to_s})"
    end
  end

  # Retorna a classe e cumprimento correto dependendo do tipo de mensagem flash.
  def flash_message(type)
    case type
    when :info then ["info", "Aviso."]
    when :notice then ["success", "Muito bem!"]
    when :error then ["warning", "Opa!"]
    end
  end

  # Define o ícone a ser usado dependendo do papel.
  def role_icon(role)
    case role
    when Role[:environment_admin] then "manager"
    when Role[:teacher] then "teacher"
    when Role[:tutor] then "tutor"
    when Role[:member] then "member"
    end
  end
end

ActionView::Base.send(:include, AsyncJSHelper)
