class EmailNotificationPreference < ApplicationRecord
  belongs_to :user

  TIMING_OPTIONS = {
    'at_time' => 'At time of event',
    'day_of' => 'Day of Event',
    'day_before' => 'Day Before',
    'two_days_before' => '2 Days Before',
    'week_before' => 'Week Before',
    'two_weeks_before' => '2 Weeks Before',
    'month_before' => 'A Month Before'
  }.freeze

  validates :user_id, uniqueness: true
  validates :event_reminder_timing, inclusion: { in: TIMING_OPTIONS.keys }, allow_nil: true, allow_blank: true
  validates :gift_reminder_timing, inclusion: { in: TIMING_OPTIONS.keys }, allow_nil: true, allow_blank: true

  after_initialize :set_default_preferences

  private

  def set_default_preferences
    self.event_reminders_enabled = true if event_reminders_enabled.nil?
    self.gift_reminders_enabled = true if gift_reminders_enabled.nil?
    self.event_reminder_timing = 'day_before' if event_reminder_timing.nil?
    self.gift_reminder_timing = 'week_before' if gift_reminder_timing.nil?
  end
end
