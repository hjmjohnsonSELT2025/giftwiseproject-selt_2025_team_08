class User < ApplicationRecord
  has_secure_password
  has_many :contacts, dependent: :destroy
  has_many :contact_users, through: :contacts, source: :contact_user
  has_many :created_events, class_name: 'Event', foreign_key: 'creator_id', dependent: :destroy
  has_many :event_attendees, dependent: :destroy
  has_many :attended_events, through: :event_attendees, source: :event
  has_many :discussion_messages, dependent: :destroy
  has_many :wish_list_items, dependent: :destroy

  GENDERS = ["Male", "Female", "Non-binary", "Prefer not to say"].freeze

  scope :available_for_contact, ->(user) { where.not(id: [user.id] + user.contact_users.pluck(:id)) }

  before_validation :downcase_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :password_confirmation, presence: true, if: :password_present?

  validates :first_name, :last_name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :date_of_birth, presence: true
  validates :gender, presence: true, inclusion: { in: GENDERS, message: "is not a valid gender" }
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
