class Participant < ApplicationRecord
  belongs_to :challenge
  belongs_to :user, optional: true
  has_many :checkins, dependent: :destroy

  validates :name, presence: { message: "conta como você quer ser chamado" }
  validates :person_token, presence: true, uniqueness: { scope: :challenge_id }

  scope :ordered, -> { order(:created_at) }

  def checked_in_on?(date)
    checkin_for(date).present?
  end

  def checkin_for(date)
    checkins.detect { |checkin| checkin.date == date }
  end
end
