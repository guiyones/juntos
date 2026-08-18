class MagicLink < ApplicationRecord
  CODE_LENGTH = 6
  EXPIRATION = 15.minutes

  belongs_to :user

  scope :active, -> { where(expires_at: Time.current...) }

  before_validation :generate_code, :set_expiration, on: :create

  validates :code, presence: true, uniqueness: true

  def self.consume(code)
    active.find_by(code: code.to_s.strip)&.consume
  end

  def consume
    destroy
    self
  end

  private
    def generate_code
      self.code ||= loop do
        candidate = SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0")
        break candidate unless self.class.exists?(code: candidate)
      end
    end

    def set_expiration
      self.expires_at ||= EXPIRATION.from_now
    end
end
