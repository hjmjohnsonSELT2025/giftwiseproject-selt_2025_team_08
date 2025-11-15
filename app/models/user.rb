class User < ApplicationRecord
  has_secure_password

  before_validation :downcase_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :password_confirmation, presence: true, if: :password_present?

  validates :first_name, :last_name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :date_of_birth, presence: true
  validates :gender, presence: true
  validates :occupation, presence: true, length: { minimum: 1, maximum: 100 }
  validates :street, :city, :state, :country, presence: true, length: { minimum: 1, maximum: 255 }
  validates :zip_code, presence: true, length: { minimum: 1, maximum: 20 }

  private

  def password_present?
    password.present?
  end

  def downcase_email
    self.email = email.to_s.downcase.strip
  end
end
