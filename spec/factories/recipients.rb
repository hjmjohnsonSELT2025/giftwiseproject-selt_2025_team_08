FactoryBot.define do
  factory :recipient do
    event { association :event }
    sequence(:first_name) { |n| "Recipient#{n}" }
    sequence(:last_name) { |n| "Name#{n}" }
    age { 30 }
    hobbies { 'Reading, Gaming' }
    likes { 'Coffee, Music' }
    dislikes { 'Crowds, Spicy food' }
  end
end
