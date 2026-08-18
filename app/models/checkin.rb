class Checkin < ApplicationRecord
  belongs_to :participant

  delegate :challenge, to: :participant

  validates :date, presence: true, uniqueness: { scope: :participant_id }
  validate :date_is_today_or_yesterday, on: :create
  validate :date_within_challenge, on: :create

  after_create_commit  { broadcast_room_later }
  after_destroy_commit { broadcast_room_now }

  private
    # Broadcast from `challenge`, not from `self`: Turbo::Broadcastable auto-injects
    # the calling record into `locals` under its element name (e.g. `checkin: self`).
    # `challenges/_room` declares strict locals `(challenge:)` only, so a `checkin:`
    # local raises "unknown local". Broadcasting from `challenge` makes the
    # auto-injected local `challenge: self`, which matches what we already pass.
    #
    # broadcast_replace_later_to also runs in a job that reloads the record from its
    # GlobalID before rendering. That's fine on create, but on destroy the row
    # is already gone by the time the job runs, so the job fails to deserialize
    # and gets discarded (no broadcast). Destroy needs the synchronous variant.
    def broadcast_room_later
      challenge.broadcast_replace_later_to challenge, target: "room",
        partial: "challenges/room", locals: { challenge: challenge }
    end

    def broadcast_room_now
      challenge.broadcast_replace_to challenge, target: "room",
        partial: "challenges/room", locals: { challenge: challenge }
    end

    def date_is_today_or_yesterday
      return if date.blank?
      unless [ challenge.today, challenge.today - 1 ].include?(date)
        errors.add :date, "só dá pra marcar hoje ou ontem"
      end
    end

    def date_within_challenge
      return if date.blank?
      unless (challenge.starts_on..challenge.ends_on).cover?(date)
        errors.add :date, "fora do período do desafio"
      end
    end
end
