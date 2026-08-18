class Challenge < ApplicationRecord
  TOKEN_LENGTH = 8

  belongs_to :user
  has_many :participants, dependent: :destroy

  before_validation :generate_token, on: :create

  validates :name, presence: { message: "dá um nome pro desafio" }
  validates :starts_on, presence: true
  validates :days, numericality: { only_integer: true, greater_than: 0, message: "precisa durar pelo menos 1 dia" }
  validates :token, presence: true, uniqueness: true

  scope :latest_first, -> { order(created_at: :desc) }

  def today = Date.current
  def ends_on = starts_on + days - 1
  def upcoming? = today < starts_on
  def finished? = today > ends_on
  def running? = !upcoming? && !finished?
  def grace_day? = today == ends_on + 1
  def date_for(day) = starts_on + day - 1

  def current_day
    return 0 if upcoming?
    [ (today - starts_on).to_i + 1, days ].min
  end

  def self.involving(person_token:, user: nil)
    matches = Participant.where(person_token: person_token)
    matches = matches.or(Participant.where(user: user)) if user
    where(id: matches.select(:challenge_id))
  end

  def join(name:, person_token:, user: nil)
    participants.create!(name: name, person_token: person_token, user: user)
  end

  private
    def generate_token
      self.token ||= loop do
        candidate = SecureRandom.base58(TOKEN_LENGTH)
        break candidate unless self.class.exists?(token: candidate)
      end
    end
end
