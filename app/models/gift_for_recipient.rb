class GiftForRecipient < ApplicationRecord
  self.table_name = 'gifts_for_recipients'
  
  belongs_to :recipient
  belongs_to :user

  validates :idea, presence: true
end
