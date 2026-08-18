require "test_helper"

class SessionsFlowTest < ActionDispatch::IntegrationTest
  test "email conhecido recebe código e verifica" do
    assert_enqueued_emails 1 do
      post session_path, params: { email: users(:gui).email }
    end
    assert_redirected_to new_verification_path

    post verification_path, params: { code: MagicLink.last.code }
    assert_redirected_to root_path

    get new_challenge_path
    assert_response :success  # está logado
  end

  test "email novo cria a conta na hora" do
    assert_difference -> { User.count } do
      post session_path, params: { email: "nova@example.com" }
    end
  end

  test "email inválido volta pro formulário" do
    assert_no_difference -> { User.count } do
      post session_path, params: { email: "nao-e-email" }
    end
    assert_redirected_to new_session_path
  end

  test "código errado não loga" do
    post session_path, params: { email: users(:gui).email }
    post verification_path, params: { code: "000000" }
    assert_redirected_to new_verification_path

    get new_challenge_path
    assert_redirected_to new_session_path  # continua deslogado
  end

  test "código de outra pessoa não loga" do
    code = users(:ana).magic_links.create!.code

    post session_path, params: { email: users(:gui).email }
    post verification_path, params: { code: code }

    get new_challenge_path
    assert_redirected_to new_session_path
  end

  test "logout" do
    sign_in_as users(:gui)
    delete session_path

    get new_challenge_path
    assert_redirected_to new_session_path
  end

  test "volta pra onde estava depois de logar" do
    get new_challenge_path
    assert_redirected_to new_session_path

    sign_in_as users(:gui)
    assert_redirected_to new_challenge_path
  end
end
