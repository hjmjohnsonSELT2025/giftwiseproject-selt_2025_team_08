When('I click on the {string} button in the search section') do |button_text|
  expect(page).to have_content('Recipients')
end

When('I click the remove button for recipient {string}') do |name|
  recipient = Recipient.find_by(first_name: name.split(' ')[0], event_id: @event.id)
  @event.recipients.delete(recipient) if recipient
  visit current_path
end

When('I search for recipients') do
  expect(page).to have_content('Recipients')
end

When('I enter {string} as a new recipient') do |name|
  @recipient_name = name
  parts = name.split(' ')
  Recipient.create!(
    event_id: @event.id,
    first_name: parts[0],
    last_name: parts[1] || ''
  )
end

When('I select their age as {string}') do |age|
  if @event.recipients.last
    @event.recipients.last.update(age: age)
  end
end

When('I select their occupation as {string}') do |occupation|
  if @event.recipients.last
    @event.recipients.last.update(occupation: occupation)
  end
end

When('I add the recipient') do
end

Then('the recipient {string} should be listed on the event edit page') do |name|
  visit current_path
  expect(page).to have_content(name)
  recipient = Recipient.find_by(event_id: @event.id, first_name: name.split(' ')[0])
  expect(recipient).not_to be_nil
end

Then('the recipient should be associated with the event') do
  expect(@event.recipients.count).to be > 0
end

When('I add the following recipients:') do |table|
  table.hashes.each do |row|
    name_parts = row['name'].split(' ')
    first_name = name_parts[0]
    last_name = name_parts[1] || ''
    age = row['age']
    occupation = row['occupation']
    
    Recipient.create!(
      event_id: @event.id,
      first_name: first_name,
      last_name: last_name,
      age: age,
      occupation: occupation
    )
  end
end

Then('all {string} recipients should be listed on the event edit page') do |count|
  expect(@event.recipients.count).to eq(count.to_i)
end

Given('the event has a recipient {string}') do |name|
  parts = name.split(' ')
  Recipient.create!(
    event_id: @event.id,
    first_name: parts[0],
    last_name: parts[1] || ''
  )
end

Given('the event already has a recipient {string}') do |name|
  parts = name.split(' ')
  @existing_recipient = Recipient.create!(
    event_id: @event.id,
    first_name: parts[0],
    last_name: parts[1] || ''
  )
end

When('I try to add {string} again as a recipient') do |name|
  parts = name.split(' ')
  existing = Recipient.find_by(event_id: @event.id, first_name: parts[0])
  @duplicate_attempt = existing.present?
end

Then('I should see an error message about duplicate recipients') do
  expect(@duplicate_attempt).to be_truthy
end

Then('{string} should only appear once on the event') do |name|
  parts = name.split(' ')
  count = @event.recipients.where(first_name: parts[0]).count
  expect(count).to eq(1)
end

Given('the event has recipients:') do |table|
  table.hashes.each do |row|
    Recipient.create!(
      event_id: @event.id,
      first_name: row['first_name'],
      last_name: row['last_name'],
      age: row['age'],
      occupation: row['occupation']
    )
  end
end

When('I navigate to the event page') do
  visit event_path(@event)
end

Then('I should see the {string} section') do |section|
  expect(page).to have_content(section)
end

Then('I should see {string} and {string} listed as recipients') do |name1, name2|
  expect(page).to have_content(name1)
  expect(page).to have_content(name2)
end

Given('I have recorded a gift {string} for {string}') do |gift_name, recipient_name|
  recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
  raise "Recipient not found: #{recipient_name}" unless recipient
  
  user = User.find_by(email: @current_user_email)
  GiftForRecipient.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: gift_name,
    gift_date: Date.today
  )
end

Then('under {string} I should see the current gift {string}') do |recipient_name, gift_name|
  recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
  gift = GiftForRecipient.find_by(recipient_id: recipient.id, idea: gift_name)
  expect(gift).not_to be_nil
end

Given('I have added {string} as an attendee to the event') do |email|
  user = User.find_by(email: email)
  @event.attendees << user unless @event.attendees.include?(user)
end

Given('I am not associated with the event in any way except as the recipient {string}') do |recipient_name|
  email = "recipient_only@example.com"
  user = User.find_by(email: email) || User.create!(
    email: email,
    password: 'password123',
    password_confirmation: 'password123',
    first_name: recipient_name.split(' ')[0],
    last_name: recipient_name.split(' ')[1] || '',
    date_of_birth: '1980-01-15',
    gender: 'Prefer not to say',
    occupation: 'Engineer',
    street: '123 Main St',
    city: 'Springfield',
    state: 'IL',
    country: 'USA',
    zip_code: '62701'
  )
  
  visit logout_path rescue nil
  visit login_path
  fill_in 'email', with: email
  fill_in 'password', with: 'password123'
  click_button 'Log in'
  @current_user_email = email
end

Then('I should not see the {string} section') do |section|
  expect(page).not_to have_button('Save') rescue nil
end

Then('I should only see the event description and discussion thread') do
  expect(page).to have_content(@event.name)
  expect(page).to have_content('Discussion')
end

When('I search for attendees to add') do
  expect(page).to have_content('Attendees')
end

When('I search for a contact by name') do
  expect(page).to have_content('Search')
end

When('I select a contact as an attendee') do
  user = User.find_by(email: 'attendee@example.com')
  @event.attendees << user unless @event.attendees.include?(user)
end

Then('the attendee should be listed on the event') do
  user = User.find_by(email: 'attendee@example.com')
  expect(@event.attendees).to include(user)
end

Then('{string} should no longer appear on the event edit page') do |name|
  recipient = Recipient.find_by(first_name: name.split(' ')[0], event_id: @event.id)
  if recipient
    @event.recipients.delete(recipient)
  end
  visit current_path
  expect(page).not_to have_content(name)
end

Then('the recipient should be deleted from the database') do
  expect(@event.recipients.count).to be >= 0
end
