FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { 'John' }
    last_name { 'Doe' }
    date_of_birth { '1990-01-15' }
    gender { 'Male' }
    occupation { 'Engineer' }
    hobbies { 'Reading, Gaming' }
    likes { 'Coffee, Technology' }
    dislikes { 'Bugs' }
    street { '123 Main St' }
    city { 'Springfield' }
    state { 'IL' }
    zip_code { '62701' }
    country { 'USA' }
  end
end
