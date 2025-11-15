require 'capybara/rails'

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end

def create_test_user(email = 'user@example.com', password = 'password123')
  User.create!(
    email: email,
    password: password,
    password_confirmation: password,
    first_name: 'Test',
    last_name: 'User',
    date_of_birth: '1990-01-15',
    gender: 'Male',
    occupation: 'Developer',
    street: '123 Main St',
    city: 'Springfield',
    state: 'IL',
    country: 'USA',
    zip_code: '62701'
  )
end

Given('a user exists with email {string} and password {string}') do |email, password|
  User.find_or_create_by(email: email) do |user|
    user.password = password
    user.password_confirmation = password
    user.first_name = 'Test'
    user.last_name = 'User'
    user.date_of_birth = '1990-01-15'
    user.gender = 'Male'
    user.occupation = 'Developer'
    user.street = '123 Main St'
    user.city = 'Springfield'
    user.state = 'IL'
    user.country = 'USA'
    user.zip_code = '62701'
  end
end

Given('I am on the home page') do
  visit '/'
end

When('I navigate to {string}') do |path|
  visit path
end

When('I click on {string}') do |link_text|
  click_link(link_text)
end

When('I click {string}') do |button_text|
  click_button(button_text)
end

Given('I am signed in as {string} with password {string}') do |email, password|
  visit '/login'
  fill_in 'email', with: email
  fill_in 'password', with: password
  click_button 'Log in'
end

When('I sign out') do
  click_button 'Logout'
end

When('I fill in {string} with {string}') do |field, value|
  begin
    fill_in(field, with: value)
  rescue Capybara::ElementNotFound
    begin
      fill_in("user_#{field}", with: value)
    rescue Capybara::ElementNotFound
      select(value, from: "user_#{field}")
    end
  end
end

When('I press Enter') do
  find('input[type="search"]').native.send_keys(:return)
end

When('I select {string} from {string}') do |option, field|
  select(option, from: field)
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

Then('I should see the registration page') do
  expect(page).to have_content('Sign up')
end

Then('I should see the login page') do
  expect(page).to have_content('Log in')
end

Then('I should be on the login page') do
  expect(page).to have_current_path('/login')
end

Then('I should be on the home page') do
  expect(page).to have_current_path('/')
end

Then('I should be redirected to the login page') do
  expect(page).to have_current_path('/login')
end

Then('I should see the new event form') do
  expect(page).to have_selector('form')
end

Then('I should see {string} or settings form elements') do |text|
  has_text = page.has_content?(text) || page.has_content?('Settings') || page.has_selector?('form')
  expect(has_text).to be true
end

Then('I should be on the {string} page') do |page_name|
  case page_name
  when 'home page'
    expect(page).to have_current_path('/')
  when 'login page'
    expect(page).to have_current_path('/login')
  when 'events page'
    expect(page).to have_current_path('/events')
  when 'settings page'
    expect(page).to have_current_path('/settings')
  when 'registration page'
    expect(page).to have_current_path('/registrations/new')
  when 'new event form'
    expect(page).to have_current_path('/events/new')
  end
end

Then('I should be redirected to the {string} page') do |page_name|
  case page_name
  when 'login page'
    expect(page).to have_current_path('/login')
  when 'home page'
    expect(page).to have_current_path('/')
  end
end

Then('I should see the {string} page') do |page_name|
  case page_name
  when 'registration page'
    expect(page).to have_content('Sign Up')
  when 'login page'
    expect(page).to have_content('Sign In')
  when 'events page'
    expect(page).to have_content('Events')
  when 'settings page'
    expect(page).to have_content('Account Settings')
  end
end

Then('I should see the {string} form') do |form_name|
  case form_name
  when 'new event'
    expect(page).to have_selector('form')
  when 'registration'
    expect(page).to have_field('email')
    expect(page).to have_field('password')
  end
end

Then('I should see a {string} link') do |link_text|
  expect(page).to have_link(link_text)
end

Then('the page should have a sign in link') do
  expect(page).to have_link('Sign In')
end

Then('the page should have a sign up link') do
  expect(page).to have_link('Sign Up')
end

Then('I should see form fields for profile information') do
  expect(page).to have_selector('form')
end

Then('the page should have links for authenticated user') do
  expect(page).to have_link('Home')
  expect(page).to have_link('Events')
  expect(page).to have_link('Settings')
  expect(page).to have_button('Logout')
end

Then('I should see the search bar') do
  expect(page).to have_field('q')
end

Then('I should see {string} button') do |button_name|
  expect(page).to have_button(button_name)
end

Then('I should see the new contact form') do
  expect(page).to have_selector('form')
end
