FactoryBot.define do
  factory :wish_list_item do
    user
    sequence(:name) { |n| "Wish List Item #{n}" }
    description { 'A great item I would love to receive' }
    url { 'https://example.com/product' }
    price { 49.99 }
  end
end
