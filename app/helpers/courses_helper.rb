# -*- encoding : utf-8 -*-
module CoursesHelper
  # Retorna a legenda adequada para o tipo de privacidade de um curso.
  def course_privacy_legend(course)
    # Todos.
    if course.subscription_type == 1
      if can?(:read, course)
        legend = "Entrada livre — Você já faz parte deste curso."
      else
        legend = "Entrada livre — Você não faz parte deste curso. "
      end
    # Entrada moderada.
    else
      if can?(:show, course)
        legend = "Entrada moderada — Você já faz parte deste curso."
      else
        legend = "Entrada moderada — Este curso requer aprovação de matrícula."
      end
    end

    content_tag :strong, legend, :class => "privacy-legend"
  end
end
