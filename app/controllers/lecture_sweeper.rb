# -*- encoding : utf-8 -*-
class LectureSweeper < ActionController::Caching::Sweeper
  observe Lecture

  def after_create(lecture)
    expire_cache_for(lecture)
  end

  # If our sweeper detects that a lecture was updated call this
  def after_update(lecture)
    expire_cache_for(lecture)
  end

  def after_show(lecture)
    expire_cache_for(lecture)
  end

  # If our sweeper detects that a lecture was deleted call this
  def after_destroy(lecture)
    expire_cache_for(lecture)
  end
end
