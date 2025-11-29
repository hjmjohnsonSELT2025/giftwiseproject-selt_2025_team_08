class DiscussionMessage < ApplicationRecord
  belongs_to :discussion
  belongs_to :user

  validates :discussion_id, presence: true
  validates :user_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 5000 }

  scope :ordered, -> { order(created_at: :asc) }
end
