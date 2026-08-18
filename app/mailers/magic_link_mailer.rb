class MagicLinkMailer < ApplicationMailer
  def sign_in_code(magic_link)
    @magic_link = magic_link
    mail to: magic_link.user.email, subject: "Seu código do Juntos é #{magic_link.code}"
  end
end
