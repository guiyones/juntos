require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  test "gera token curto ao criar" do
    challenge = users(:gui).challenges.create!(name: "Ler todo dia", starts_on: Date.current, days: 30)

    assert_match(/\A[a-zA-Z0-9]{8}\z/, challenge.token)
  end

  test "exige nome, data de início e dias positivos" do
    challenge = Challenge.new
    assert_not challenge.valid?
    assert_not users(:gui).challenges.new(name: "X", starts_on: Date.current, days: 0).valid?
  end

  test "ends_on é starts_on + days - 1" do
    assert_equal challenges(:sleep).starts_on + 20, challenges(:sleep).ends_on
  end

  test "current_day durante o desafio" do
    assert_equal 8, challenges(:sleep).current_day
    assert challenges(:sleep).running?
  end

  test "upcoming antes de começar" do
    assert challenges(:novena).upcoming?
    assert_equal 0, challenges(:novena).current_day
  end

  test "finished depois do fim e current_day trava no total" do
    travel_to challenges(:sleep).ends_on + 1.day do
      assert challenges(:sleep).finished?
      assert_equal 21, challenges(:sleep).current_day
    end
  end

  test "grace_day? só no primeiro dia depois do fim" do
    travel_to challenges(:sleep).ends_on do
      assert_not challenges(:sleep).grace_day?
    end

    travel_to challenges(:sleep).ends_on + 1.day do
      assert challenges(:sleep).grace_day?
    end

    travel_to challenges(:sleep).ends_on + 2.days do
      assert_not challenges(:sleep).grace_day?
    end
  end

  test "date_for converte dia em data" do
    assert_equal challenges(:sleep).starts_on, challenges(:sleep).date_for(1)
    assert_equal challenges(:sleep).starts_on + 7, challenges(:sleep).date_for(8)
  end

  test "join cria participante" do
    participant = challenges(:novena).join(name: "Bia", person_token: "bia-device")

    assert_equal "Bia", participant.name
    assert_nil participant.user
  end

  test "involving acha salas pelo cookie e pelo user" do
    challenges = Challenge.involving(person_token: "ana-device", user: users(:ana))
    assert_equal [ challenges(:novena), challenges(:sleep) ].sort, challenges.sort

    only_cookie = Challenge.involving(person_token: "gui-device")
    assert_equal [ challenges(:sleep) ], only_cookie.to_a
  end
end
