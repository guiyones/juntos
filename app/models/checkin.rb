class Checkin < ApplicationRecord
  belongs_to :participant

  delegate :challenge, to: :participant

  validates :date, presence: true, uniqueness: { scope: :participant_id }
  validate :date_is_today_or_yesterday, on: :create
  validate :date_within_challenge, on: :create

  private
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
