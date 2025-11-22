class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :contact_user, class_name: 'User'

  validates :user_id, :contact_user_id, presence: true
  validates :contact_user_id, uniqueness: { scope: :user_id, message: "can only be added once per user" }
  validate :cannot_add_self
  validate :contact_user_exists

  private

  def cannot_add_self
    if user_id == contact_user_id
      errors.add(:contact_user_id, "cannot add yourself as a contact")
    end
  end

  def contact_user_exists
    unless User.exists?(contact_user_id)
      errors.add(:contact_user_id, "must be a valid user")
    end
  end
end
