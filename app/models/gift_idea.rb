class GiftIdea < ApplicationRecord
  belongs_to :recipient
  belongs_to :user

  validates :idea, presence: true
end
