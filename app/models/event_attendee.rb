class EventAttendee < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :event_id, uniqueness: { scope: :user_id, message: "user is already an attendee" }
end
