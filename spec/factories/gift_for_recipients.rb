FactoryBot.define do
  factory :gift_for_recipient do
    recipient { association :recipient }
    user { association :user }
    sequence(:idea) { |n| "Gift Idea #{n}" }
    price { 50.00 }
    status { 'idea' }
    gift_date { Date.today }
  end
end
