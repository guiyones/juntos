module SessionTestHelper
  def sign_in_as(user)
    post session_path, params: { email: user.email }
    post verification_path, params: { code: MagicLink.last.code }
  end
end
