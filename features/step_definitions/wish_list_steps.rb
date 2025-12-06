Given('the user has a wish list item {string} with price {string}') do |name, price|
  user = User.find_by(email: 'user@example.com')
  WishListItem.create!(
    user: user,
    name: name,
    price: price
  )
end

Given('the user has {int} wish list items') do |count|
  user = User.find_by(email: 'user@example.com')
  count.times do |i|
    WishListItem.create!(
      user: user,
      name: "Item #{i + 1}",
      price: (i + 1) * 50.00
    )
  end
end

When('I fill in the wish list form with valid data') do
  fill_in 'wish_list_item_name', with: 'Sony WH-1000XM5 Headphones'
  fill_in 'wish_list_item_description', with: 'Amazing noise-cancelling headphones'
  fill_in 'wish_list_item_url', with: 'https://example.com/headphones'
  fill_in 'wish_list_item_price', with: '399.99'
end

When('I submit the form') do
  click_button 'Create Wish list item'
end

Then('I should see {string} in the navigation') do |text|
  within('nav') do
    expect(page).to have_content(text)
  end
end

When('I navigate to the home page') do
  visit root_path
end

