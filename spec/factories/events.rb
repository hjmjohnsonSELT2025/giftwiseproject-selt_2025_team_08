FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Event #{n}" }
    description { 'Test event description' }
    start_at { 1.day.from_now }
    end_at { 2.days.from_now }
    location { 'Test Location' }
    theme { 'General' }
    creator { association :user }
  end
end
