require "test_helper"

class JoinsControllerTest < ActionDispatch::IntegrationTest
  test "link mostra o desafio e quem já está dentro" do
    get join_path(challenges(:sleep).token)

    assert_response :success
    assert_select "h1", text: /Dormir cedo/
    assert_select "li", text: /Gui/
  end

  test "entrar cria participante e leva pra sala" do
    assert_difference -> { challenges(:sleep).participants.count } do
      post join_path(challenges(:sleep).token), params: { name: "Bia" }
    end
    assert_redirected_to challenge_path(challenges(:sleep))

    follow_redirect!
    assert_response :success  # o cookie criado no join identifica o participante
  end

  test "quem já entrou vai direto pra sala" do
    post join_path(challenges(:sleep).token), params: { name: "Bia" }

    get join_path(challenges(:sleep).token)
    assert_redirected_to challenge_path(challenges(:sleep))
  end

  test "nome vazio volta pro formulário" do
    assert_no_difference -> { Participant.count } do
      post join_path(challenges(:sleep).token), params: { name: "" }
    end
    assert_redirected_to join_path(challenges(:sleep).token)
  end

  test "token desconhecido dá 404" do
    get join_path("nao-existe")
    assert_response :not_found
  end
end
