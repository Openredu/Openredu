class Home < SitePrism::Page
  set_url "/pessoas/{/username}/home"

  #Sections
  section :header, HeaderLogged, "div.nav-global.nav-global-fixed-top div.nav-global-inner"

  #Elements
  element :welcome_message , "span.home-hello-user"

  def load(username)
    self.wait_load
    super(username: username[:username])
    self
  end

  def wait_load
    HoldOn.until(timeout: 30, interval: 0.5, message: "The Home Page did not load after 30 seconds") do
      has_welcome_message? && welcome_message.visible?
    end
  end

  def logout
    header = self.header.logout
    self
  end

end
