class Recipient < ApplicationRecord
  belongs_to :event
  has_many :gift_ideas, dependent: :destroy
  has_many :gifts_for_recipients, class_name: 'GiftForRecipient', dependent: :destroy

  validates :first_name, :last_name, presence: true
end
