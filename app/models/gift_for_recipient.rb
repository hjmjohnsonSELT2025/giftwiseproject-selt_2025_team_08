class GiftForRecipient < ApplicationRecord
  self.table_name = 'gifts_for_recipients'
  
  belongs_to :recipient
  belongs_to :user

  validates :idea, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :gift_date, presence: true, allow_nil: true
end
