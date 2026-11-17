class User < ApplicationRecord
  # bcrypt stores a password digest and checks passwords during admin sign-in.
  has_secure_password

  # Trim and lowercase email addresses before checking their format and uniqueness.
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
