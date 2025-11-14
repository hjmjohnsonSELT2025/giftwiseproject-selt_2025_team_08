class User < ApplicationRecord
  has_secure_password

  before_validation :downcase_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  private

  def downcase_email
    self.email = email.to_s.downcase.strip
  end
end
