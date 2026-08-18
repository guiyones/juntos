module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    helper_method :current_user, :signed_in?, :current_participant_for
  end

  private
    def resume_session
      Current.user = User.find_by(id: cookies.signed[:user_id])
    end

    def current_user = Current.user
    def signed_in? = current_user.present?

    def require_authentication
      unless signed_in?
        session[:return_to] = request.fullpath
        redirect_to new_session_path
      end
    end

    def sign_in(user)
      Current.user = user
      cookies.signed.permanent[:user_id] = { value: user.id, httponly: true, same_site: :lax }
    end

    def sign_out
      Current.user = nil
      cookies.delete(:user_id)
    end

    # Identidade de participante: um token permanente por navegador.
    def person_token
      cookies.signed[:person_token] || issue_person_token
    end

    def issue_person_token
      SecureRandom.base58(24).tap do |token|
        cookies.signed.permanent[:person_token] = { value: token, httponly: true, same_site: :lax }
      end
    end

    def current_participant_for(challenge)
      challenge.participants.find_by(person_token: cookies.signed[:person_token]) ||
        (challenge.participants.find_by(user: current_user) if signed_in?)
    end
end
