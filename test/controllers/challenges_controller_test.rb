require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  test "criar exige login" do
    get new_challenge_path
    assert_redirected_to new_session_path
  end

  test "criar sala já cria o participante do criador" do
    sign_in_as users(:gui)

    assert_difference -> { Challenge.count } => 1, -> { Participant.count } => 1 do
      post challenges_path, params: {
        participant_name: "Gui",
        challenge: { name: "Ler todo dia", starts_on: Date.tomorrow, days: 30 }
      }
    end

    challenge = Challenge.last
    assert_redirected_to challenge_path(challenge)
    assert_equal users(:gui), challenge.participants.first.user
  end

  test "sala inválida volta pro formulário com erro" do
    sign_in_as users(:gui)

    post challenges_path, params: { participant_name: "Gui", challenge: { name: "", starts_on: Date.tomorrow, days: 30 } }
    assert_response :unprocessable_entity
  end

  test "nome de participante em branco não cria sala órfã" do
    sign_in_as users(:gui)

    assert_no_difference [ -> { Challenge.count }, -> { Participant.count } ] do
      post challenges_path, params: {
        participant_name: "   ",
        challenge: { name: "Ler todo dia", starts_on: Date.tomorrow, days: 30 }
      }
    end

    assert_response :unprocessable_entity
  end

  test "quem não é participante não vê a sala nem o link" do
    get challenge_path(challenges(:sleep))
    assert_redirected_to root_path
    assert_not_includes response.headers["Location"], challenges(:sleep).token
  end

  test "criador logado em outro aparelho entra na própria sala" do
    sign_in_as users(:gui)
    get challenge_path(challenges(:sleep))
    assert_response :success
  end

  test "home lista minhas salas quando logado" do
    sign_in_as users(:ana)
    get root_path
    assert_response :success
    assert_select "a", text: /Novena da madrugada/
  end

  test "home vazia mostra o convite pra criar" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", new_challenge_path
  end
end
