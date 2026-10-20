class User < ApplicationRecord
  has_secure_password

  # Store email addresses consistently.
  before_validation :normalize_email

  validates :name, presence: true
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :role, inclusion: { in: %w[user admin] }

  # Require at least 12 characters when setting a password.
  validates :password,
            length: { minimum: 12 },
            if: -> { password.present? }

  def admin?
    role == "admin"
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
