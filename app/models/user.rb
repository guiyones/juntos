class User < ApplicationRecord
  has_many :magic_links, dependent: :destroy
  has_many :challenges, dependent: :destroy
  has_many :participants, dependent: :nullify

  normalizes :email, with: ->(email) { email.strip.downcase.presence }

  validates :email, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "não parece um email válido" }
end
