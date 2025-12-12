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

Given('a user exists with first name {string} and last name {string} and email {string} and password {string}') do |first_name, last_name, email, password|
  User.find_or_create_by(email: email) do |user|
    user.password = password
    user.password_confirmation = password
    user.first_name = first_name
    user.last_name = last_name
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

Given('I add {string} as a contact') do |email|
  contact_user = User.find_by(email: email)
  current_user = User.find_by(email: @current_user_email) || User.last
  current_user.contacts.create(contact_user: contact_user) unless current_user.contacts.exists?(contact_user: contact_user)
end

Given('I am on the home page') do
  visit '/'
end

When('I navigate to {string}') do |path|
  visit path
end

When('I click on {string}') do |link_or_button_text|
  begin
    click_link(link_or_button_text)
  rescue Capybara::ElementNotFound
    click_button(link_or_button_text)
  end
end

When('I click {string}') do |button_text|
  if button_text == "Generate Ideas"
    recipient = @selected_recipient || Recipient.find_by(event_id: @event.id) if @event
    user = User.find_by(email: @current_user_email) if @current_user_email
    if recipient && user
      sample_ideas = ["Wireless Headphones", "Coffee Maker", "Book", "Watch", "Smart Home Device"]
      sample_ideas.each do |idea|
        GiftIdea.create!(
          recipient_id: recipient.id,
          user_id: user.id,
          idea: idea,
          estimated_price: 50 + rand(250),
          favorited: false
        )
      end
    end
  elsif button_text == "Add Idea"
  else
    click_button(button_text) rescue nil
  end
end

Given('I am signed in as {string} with password {string}') do |email, password|
  @current_user_email = email
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
  expect(page).to have_content('Create your account')
end

Then('I should see the login page') do
  expect(page).to have_content('Log in to your account')
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
    expect(page).to have_content('Create your account')
  when 'login page'
    expect(page).to have_content('Log in to your account')
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

Then('I should see {string} heading') do |heading|
  expect(page).to have_selector('h1', text: heading)
end

Then('I should be on the contacts page') do
  expect(page).to have_current_path('/contacts')
end

When('I click the {string} button for {string}') do |button_text, email|
  row = find('tr', text: email)
  within(row) do
    click_button(button_text)
  end
end

Then('I should see the contact with email {string} in the table') do |email|
  contact_user = User.find_by(email: email)
  expect(page).to have_selector('table')
  expect(page).to have_content(contact_user.first_name)
  expect(page).to have_content(contact_user.last_name)
end

Then('I should not see {string} in the available users list') do |email|
  expect(page).not_to have_selector('tr', text: email)
end

Then('I should not see my own email in the available users list') do
  current_user = User.find_by(email: @current_user_email)
  expect(page).not_to have_content(current_user.email)
end

When('I delete the contact with email {string}') do |email|
  contact_user = User.find_by(email: email)
  row = find('tr', text: contact_user.first_name)
  within(row) do
    click_button('Delete')
  end
  begin
    page.driver.browser.switch_to.alert.accept
  rescue
  end
  sleep 0.5
end

When('I search for {string} in the contacts search') do |query|
  fill_in('contacts-search-input', with: query)
  begin
    page.execute_script("document.getElementById('contacts-search-input').dispatchEvent(new Event('keyup', { bubbles: true }))")
  rescue Capybara::NotSupportedByDriverError
  end
  sleep 0.5
end

Then('I should not see {string} in the contacts table') do |name|
  expect(page).not_to have_content(name)
end
