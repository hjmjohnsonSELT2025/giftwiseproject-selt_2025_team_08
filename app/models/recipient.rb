class Recipient < ApplicationRecord
  belongs_to :event
  has_many :gift_ideas, dependent: :destroy
  has_many :gifts_for_recipients, class_name: 'GiftForRecipient', dependent: :destroy

  validates :first_name, :last_name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 150 }, allow_nil: true
  validates :hobbies, :likes, :dislikes, length: { maximum: 1000 }, allow_nil: true
end
