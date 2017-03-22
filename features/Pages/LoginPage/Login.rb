class Login < SitePrism::Page
  set_url "/"

  #Sections
  section :header, HeaderNotLogged, "div.header-not-logged-in"

  #Elements
  element :welcome_message, "h2.landing-welcome-title"

  def press_key_element
    header.press_key_element
  end

  def load
    super()
    self.wait_load
    self
  end

  def wait_load
    HoldOn.until(timeout: 30, interval: 0.5, message: "The Login Page did not load after 30 seconds") do
      has_welcome_message? && welcome_message.visible?
    end
  end

  def open_sign_in
    header.open_sign_in
    self
  end

  def submit_login
    header.submit_login
    self
  end

  def invalid_password_display?
    header.invalid_password_display?
  end

  def empty_password_display?
    header.empty_password_display?
  end

  def invalid_username_display?
    header.invalid_username_display?
  end

  def empty_username_display?
    header.empty_username_display?
  end

  def log_with_username(username, password)
    header.log_with_username(username, password)
  end
end
