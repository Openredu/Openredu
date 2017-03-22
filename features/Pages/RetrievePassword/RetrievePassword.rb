class RetrievePassword < SitePrism::Page
  set_url "/recuperar_login_senha"

  #Elements
  element :email_input  , "input#recovery_email_email"
  element :submit_button, "input.concave-button"

  def load
    super()
    self.wait_load
    self
  end

  def wait_load
    HoldOn.until(timeout: 30, interval: 0.5, message: "The Retrive Password Page did not load after 30 seconds") do
      has_email_input? && email_input.visible?
    end
  end

  def fillEmailField(email)
    email_input.set(email)
    self
  end

  def submitEmail
    submit_button.click
    self
  end

end
