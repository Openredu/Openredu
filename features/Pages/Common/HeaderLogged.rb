class HeaderLogged < SitePrism::Section

  #Elements
  element :button_user_dropdown , "div.nav-global-buttons-dropdown"
  element :logout_button        , "div.nav-global-buttons-dropdown div.button-group.open
                                    a.nav-global-profile-item-link-iconless"

  def logout

    if(not user_dropdown_opened?) then
      button_user_dropdown.click
    end

    logout_button.click
    self
  end

  def user_dropdown_opened?
    begin
      opened_user_dropbox = button_user_dropdown.find("div.button-group.open")
      opened_user_dropbox.visible?
    rescue Capybara::ElementNotFound
      false
    end
  end
end
