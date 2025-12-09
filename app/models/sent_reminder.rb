class SentReminder < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :reminder_type, inclusion: { in: ['event', 'gift'] }
  validates :timing, presence: true
  validates :user_id, :event_id, :reminder_type, presence: true
  validates :user_id, uniqueness: { scope: [:event_id, :reminder_type], message: "can only send one reminder per event and type" }
end
