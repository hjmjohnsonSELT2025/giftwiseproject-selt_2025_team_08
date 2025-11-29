class GiftIdea < ApplicationRecord
  belongs_to :recipient
  belongs_to :user

  validates :idea, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :estimated_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :favorited, inclusion: { in: [true, false] }, allow_nil: true
end
