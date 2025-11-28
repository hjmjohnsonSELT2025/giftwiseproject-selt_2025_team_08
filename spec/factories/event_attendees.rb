FactoryBot.define do
  factory :event_attendee do
    event { association :event }
    user { association :user }
  end
end
