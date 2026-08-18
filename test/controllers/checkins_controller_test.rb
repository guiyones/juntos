require "test_helper"

class CheckinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # entra na sala "sleep" como participante novo, ganhando o cookie
    post join_path(challenges(:sleep).token), params: { name: "Bia" }
    @participant = Participant.last
  end

  test "marca hoje" do
    assert_difference -> { @participant.checkins.count } do
      post checkins_path, params: { challenge_id: challenges(:sleep).id }
    end
    assert_redirected_to challenge_path(challenges(:sleep))
    assert_equal Date.current, @participant.checkins.last.date
  end

  test "marca ontem" do
    post checkins_path, params: { challenge_id: challenges(:sleep).id, date: "yesterday" }
    assert_equal Date.yesterday, @participant.checkins.last.date
  end

  test "marcar duas vezes não duplica" do
    2.times { post checkins_path, params: { challenge_id: challenges(:sleep).id } }
    assert_equal 1, @participant.checkins.count
  end

  test "desmarca o próprio checkin" do
    checkin = @participant.checkins.create!(date: Date.current)

    assert_difference -> { Checkin.count }, -1 do
      delete checkin_path(checkin)
    end
  end

  test "não desmarca checkin dos outros" do
    checkin = participants(:gui_sleep).checkins.create!(date: Date.current)

    assert_no_difference -> { Checkin.count } do
      delete checkin_path(checkin)
    end
    assert_response :forbidden
  end

  test "quem não participa não marca" do
    post join_path(challenges(:novena).token), params: { name: "Bia" }  # entra em outra sala
    reset!  # nova sessão, sem cookies

    assert_no_difference -> { Checkin.count } do
      post checkins_path, params: { challenge_id: challenges(:sleep).id }
    end
    assert_response :forbidden
  end
end
