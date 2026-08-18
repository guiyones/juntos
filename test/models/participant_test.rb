require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  test "exige nome" do
    participant = challenges(:sleep).participants.new(person_token: "novo-device")
    assert_not participant.valid?
  end

  test "mesmo person_token não entra duas vezes na mesma sala" do
    assert_raises ActiveRecord::RecordInvalid do
      challenges(:sleep).participants.create!(name: "Gui de novo", person_token: "gui-device")
    end
  end

  test "mesmo person_token pode estar em salas diferentes" do
    assert_nothing_raised do
      challenges(:novena).participants.create!(name: "Gui", person_token: "gui-device")
    end
  end
end
