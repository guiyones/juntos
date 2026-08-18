require "test_helper"

class CheckinBroadcastTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  test "criar checkin transmite a sala atualizada" do
    challenge = challenges(:sleep)

    assert_broadcasts challenge.to_gid_param, 1 do
      perform_enqueued_jobs do
        participants(:gui_sleep).checkins.create!(date: Date.current)
      end
    end
  end

  test "desfazer também transmite" do
    checkin = participants(:gui_sleep).checkins.create!(date: Date.current)

    assert_broadcasts challenges(:sleep).to_gid_param, 1 do
      perform_enqueued_jobs do
        checkin.destroy
      end
    end
  end
end
