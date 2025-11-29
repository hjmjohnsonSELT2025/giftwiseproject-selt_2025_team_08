class Event < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  has_many :recipients, dependent: :destroy
  has_many :event_attendees, dependent: :destroy
  has_many :attendees, through: :event_attendees, source: :user
  has_many :discussions, dependent: :destroy

  validates :name, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :creator_id, presence: true

  validate :end_after_start

  scope :upcoming_this_month, ->(user) {
    now = Time.current
    month_start = now.beginning_of_month
    month_end = now.end_of_month

    joins("LEFT JOIN event_attendees ON events.id = event_attendees.event_id")
      .joins("LEFT JOIN recipients ON events.id = recipients.event_id")
      .where("event_attendees.user_id = ? OR events.creator_id = ? OR (recipients.first_name = ? AND recipients.last_name = ?)", 
             user.id, user.id, user.first_name, user.last_name)
      .where("events.start_at >= ? AND events.start_at <= ?", month_start, month_end)
      .group("events.id")
      .order("events.start_at")
  }

  private

  def end_after_start
    return if start_at.blank? || end_at.blank?
    errors.add(:end_at, 'must be after start date/time') if end_at < start_at
  end
end
