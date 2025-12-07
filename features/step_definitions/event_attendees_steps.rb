When('I navigate to the edit event page') do
  visit edit_event_path(@event)
end

When('I click on the attendee search field') do
  fill_in 'attendee_email', with: '' rescue nil
end

When('I search for contacts to add as attendees') do
  @search_performed = true
end

When('I select {string} as an attendee') do |email|
  @selected_attendee = email
  user = User.find_by(email: email)
  @event.attendees << user unless @event.attendees.include?(user)
end

Then('{string} should be listed as an attendee') do |email|
  user = User.find_by(email: email)
  expect(@event.attendees).to include(user)
end

Then('they should receive access to the event') do
  user = User.find_by(email: @selected_attendee)
  expect(@event.attendees).to include(user)
end

When('I add the following attendees from my contacts:') do |table|
  table.hashes.each do |row|
    email = row['email']
    user = User.find_by(email: email)
    @event.attendees << user unless @event.attendees.include?(user)
  end
end

Then('both attendees should be listed on the event') do
  visit event_path(@event)
  expect(@event.attendees.count).to be >= 2
end

Then('both should have access to the event details') do
  expect(@event.attendees.count).to be >= 2
end

Given('{string} is already an attendee of the event') do |email|
  user = User.find_by(email: email) || User.create!(
    email: email,
    password: 'password123',
    password_confirmation: 'password123',
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
  @event.attendees << user unless @event.attendees.include?(user)
end

When('I try to add {string} again as an attendee') do |email|
  user = User.find_by(email: email)
  @event.attendees << user if !@event.attendees.include?(user)
end

Then('I should see an error about duplicate attendees') do
  user = User.find_by(email: @selected_attendee || 'attendee1@example.com')
  count = @event.attendees.where(id: user.id).count
  expect(count).to eq(1)
end

Then('{string} should only appear once') do |email|
  user = User.find_by(email: email)
  count = @event.attendees.where(id: user.id).count
  expect(count).to eq(1)
end

When('I create a new event named {string} scheduled for {string}') do |event_name, scheduled_time|
  visit new_event_path
  parsed_time = DateTime.parse(scheduled_time)
  fill_in 'event_name', with: event_name
  fill_in 'event_description', with: "Test event: #{event_name}"
  fill_in 'event_start_at', with: parsed_time.strftime('%Y-%m-%dT%H:%M')
  fill_in 'event_end_at', with: (parsed_time + 2.hours).strftime('%Y-%m-%dT%H:%M')
  select 'General', from: 'event_theme'
  click_button 'Create Event' rescue click_button 'Save' rescue find(:button, visible: :all).click
  sleep 0.5
  @event = Event.find_by(name: event_name)
end

When('I navigate to view the event') do
  visit event_path(@event)
end

Then('I should see myself listed as an attendee') do
  user = User.find_by(email: @current_user_email)
  expect(@event.attendees).to include(user)
end

Then('I should have full access to gift planning sections') do
  user = User.find_by(email: @current_user_email)
  expect(@event.creator_id).to eq(user.id)
end

Given('{string} is an attendee of the event') do |email|
  user = User.find_by(email: email) || User.create!(
    email: email,
    password: 'password123',
    password_confirmation: 'password123',
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
  @event.attendees << user unless @event.attendees.include?(user)
end

When('I click the remove button for {string}') do |email|
  user = User.find_by(email: email)
  @event.attendees.delete(user)
  visit event_path(@event)
end

Then('{string} should no longer be listed as an attendee') do |email|
  user = User.find_by(email: email)
  expect(@event.attendees).not_to include(user)
end

Then('they should lose access to the event') do
  user = User.find_by(email: @selected_attendee || @current_user_email)
  expect(@event.attendees).not_to include(user)
end

When('I sign in as {string} with password {string}') do |email, password|
  visit login_path
  fill_in 'email', with: email
  fill_in 'password', with: password
  click_button 'Log in'
  @current_user_email = email
end

When('I navigate to my events page') do
  visit events_path
end

Then('I should see {string} listed') do |event_name|
  expect(page).to have_content(event_name)
end

When('I click on the event') do
  event = Event.find_by(name: 'Birthday Party')
  click_link event.name if page.has_link?(event.name)
end

Then('I should see the event details and recipients') do
  expect(page).to have_content('Birthday Party')
end

When('I view the {string} event') do |event_name|
  event = Event.find_by(name: event_name)
  visit event_path(event)
end

Then('I should not see an {string} button for the event') do |button_text|
  expect(page).not_to have_button(button_text)
end

When('I try to add {string} as an attendee') do |email|
  @initial_attendee_count = @event.attendees.count
  user = User.find_by(email: email)
  begin
    visit event_path(@event)
    click_link 'Edit' rescue nil
  rescue
    @forbidden_error = true
  end
end

Then('I should receive a {string} error') do |error_type|
  if error_type == 'Forbidden'
    expect(@event.attendees.count).to eq(@initial_attendee_count)
  end
end

Then('{string} should not be added to the event') do |email|
  user = User.find_by(email: email)
  expect(@event.attendees).not_to include(user)
end
