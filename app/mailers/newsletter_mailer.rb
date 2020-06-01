# -*- encoding : utf-8 -*-
class NewsletterMailer < BaseMailer
  # Envia newsletter para o e-mail passado.
  #
  # :user, instância do usuário
  # :template, template a ser usado
  # :subject, assunto do e-mail
  # :opts, informações disponíveis através de @vars na view
  #
  # Para enviar e-mail para todos usuários, é recomendado utilizar o
  # find_in_batches para evitar estouro de memória:
  #
  #   User.find_in_batches(:batch_size => 100) do |users|
  #     users.each do |u|
  #       subject = "Professor e Aluno, precisamos de você!"
  #       email = u.email
  #       mail = UserNotifier.newsletter(email, :template => "newsletter/news.html.erb",
  #                                      :subject => subject)
  #       mail.deliver
  #     end
  #   end
  def newsletter(email, opts={})
    subject = opts.delete(:subject) || "Novidades do #{Redu::Application.config.name}"
    template = opts.delete(:template) || "newsletter/newsletter"
    @vars = { :email => email }.merge(opts)

    mail(:to => email, :subject => subject) do |format|
      format.html { render :template => template, :layout => false }
    end
  end
end
