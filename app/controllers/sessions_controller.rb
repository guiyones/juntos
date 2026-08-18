class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: "Muitas tentativas. Espera uns minutos." }

  def new
  end

  def create
    user = User.find_or_create_by!(email: User.normalize_value_for(:email, email_param))
    magic_link = user.send_magic_link

    session[:pending_email] = user.email
    flash[:dev_code] = magic_link.code if Rails.env.development?
    redirect_to new_verification_path
  rescue ActiveRecord::RecordInvalid
    redirect_to new_session_path, alert: "Esse email não parece válido."
  rescue ActiveRecord::RecordNotUnique
    # Duas requisições concorrentes criando o mesmo email: a perdedora bate no índice
    # único do banco. Tenta de novo — dessa vez find_or_create_by! encontra o registro
    # que a outra requisição acabou de criar.
    retry
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private
    def email_param
      params.expect(:email)
    end
end
