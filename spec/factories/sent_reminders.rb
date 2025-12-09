FactoryBot.define do
  factory :sent_reminder do
    user { association :user }
    event { association :event }
    reminder_type { 'event' }
    timing { 'day_before' }
  end
end
