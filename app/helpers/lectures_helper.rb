# -*- encoding : utf-8 -*-
module LecturesHelper
  include SpacesHelper

  def user_existent_lectures
    existent_lectures = current_user.lectures.collect do |l|
      # Não mostra os Seminars não convertidos.
      [l.name, "#{l.id.to_s}"] unless (l.lectureable.class.to_s.eql? "Seminar") and
      (not l.lectureable.state.eql? "converted")
    end
    existent_lectures.compact!
    existent_lectures
  end

  def render_player(options = {})
    options = {
      :width => '608',
      :height => '360',
    }.merge(options)

    result = <<-END
        <iframe width="#{options[:width]}"
          height="#{options[:height]}"
          src="#{options[:youtube_url]}"
          frameborder="0"
          allowfullscreen="allowfullscreen"
          mozallowfullscreen="mozallowfullscreen"
          msallowfullscreen="msallowfullscreen"
          oallowfullscreen="oallowfullscreen"
          webkitallowfullscreen="webkitallowfullscreen">
        </iframe>
    END

    result.html_safe
  end

  def mark_lecture_icon(done)
    if done
      "icon-class-green_16_18-before"
    else
      "icon-class-gray_16_18-before"
    end
  end

  def disable_label_if(disable)
    "disabled" if disable
  end

  def add_tiptip_if_disabled(disable, &block)
    body = capture(&block)

    if disable
      content_tag(:span, body, :class => "tiptip", :title => "Estamos" \
                  " processando esta aula, por favor, aguarde. Em instantes" \
                  " você poderá finalizá-la.")
    else
      body
    end
  end
end
