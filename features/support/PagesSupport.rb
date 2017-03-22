class PagesSupport

  def self.get_page(page_name)

    pages_names ={
                "Login" => "Login", "login" => "Login",
                "Home" => "Home", "home" => "Home",
                "Retrieve Password" => "RetrievePassword", "Retrieve_Password" => "RetrievePassword"
              }

    begin
      return pages_names[page_name].constantize.new
    rescue NameError
      raise PageNotFoundEroor, "There is no page named #{page_name}."
    end
  end

  def self.press_key(page, key)
    keys = {
            "Enter" => :return,
            "enter" => :return
          }

    if not keys.has_key?(key)
      raise UndefinedKeyError, "There is no #{key} key defined."
    end

    begin
      page.press_key_element.native.send_keys keys[key]
    rescue NoMethodError => e
      raise e!, "The current page need to define a method called press_key_element.", e!.backtrace
    end
  end
end
