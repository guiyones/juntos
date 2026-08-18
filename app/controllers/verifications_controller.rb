class VerificationsController < ApplicationController
  rate_limit to: 10, within: 15.minutes, only: :create,
    with: -> { redirect_to new_verification_path, alert: "Muitas tentativas. Espera 15 minutos." }

  def new
    redirect_to new_session_path if pending_email.blank?
  end

  def create
    magic_link = MagicLink.consume(params.expect(:code))

    if magic_link && magic_link.user.email == pending_email
      sign_in magic_link.user
      session.delete(:pending_email)
      redirect_to session.delete(:return_to) || root_path
    else
      redirect_to new_verification_path, alert: "Código errado ou vencido. Tenta de novo?"
    end
  end

  private
    def pending_email
      session[:pending_email]
    end
end
