class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :clients, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name,
            length: { maximum: 50 },
            allow_blank: true

  validates :last_name,
            length: { maximum: 50 },
            allow_blank: true
  
  validates :company_name,
            length: { maximum: 100 },
            allow_blank: true

  validates :email_address,
            presence: true,
            uniqueness: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: "must be a valid email address"
            }

  generates_token_for :email_verification, expires_in: 24.hours do
    email_address
  end

  def email_verified?
    email_verified_at.present?
  end
end
