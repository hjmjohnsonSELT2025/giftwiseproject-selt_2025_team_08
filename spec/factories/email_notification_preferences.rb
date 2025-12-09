FactoryBot.define do
  factory :email_notification_preference do
    user { association :user }
    event_reminders_enabled { true }
    event_reminder_timing { 'day_before' }
    gift_reminders_enabled { true }
    gift_reminder_timing { 'week_before' }
  end
end
