require "test_helper"

class CheckinTest < ActiveSupport::TestCase
  setup do
    @participant = participants(:gui_sleep)  # desafio "sleep" está no dia 8 de 21
  end

  test "marca hoje" do
    assert @participant.checkins.create(date: Date.current).persisted?
  end

  test "marca ontem" do
    assert @participant.checkins.create(date: Date.yesterday).persisted?
  end

  test "não marca anteontem nem amanhã" do
    assert_not @participant.checkins.create(date: Date.current - 2).persisted?
    assert_not @participant.checkins.create(date: Date.current + 1).persisted?
  end

  test "não marca antes do desafio começar" do
    participant = challenges(:novena).participants.create!(name: "Bia", person_token: "bia-device")
    assert_not participant.checkins.create(date: Date.current).persisted?
  end

  test "não marca depois do desafio acabar" do
    travel_to challenges(:sleep).ends_on + 2.days do
      assert_not @participant.checkins.create(date: Date.current).persisted?
    end
  end

  test "ontem vale quando hoje é o primeiro dia depois do fim" do
    travel_to challenges(:sleep).ends_on + 1.day do
      assert @participant.checkins.create(date: Date.yesterday).persisted?
    end
  end

  test "não duplica o mesmo dia" do
    @participant.checkins.create!(date: Date.current)
    assert_not @participant.checkins.create(date: Date.current).persisted?
  end

  test "checked_in_on? funciona com checkins pré-carregados" do
    @participant.checkins.create!(date: Date.current)
    loaded = Participant.includes(:checkins).find(@participant.id)

    assert loaded.checked_in_on?(Date.current)
    assert_not loaded.checked_in_on?(Date.yesterday)
  end
end
