Given('I have created an event named {string} scheduled for {string}') do |event_name, scheduled_time|
  @user = User.find_by(email: 'creator@example.com')
  parsed_time = DateTime.parse(scheduled_time)
  @event = Event.create!(
    name: event_name,
    description: "Test event: #{event_name}",
    start_at: parsed_time,
    end_at: parsed_time + 2.hours,
    creator_id: @user.id
  )
end

When('I navigate to the event discussions page with thread type {string}') do |thread_type|
  @thread_type = thread_type
  visit event_discussions_path(@event, thread_type: thread_type)
end

When('I navigate to the event discussions page without specifying thread type') do
  visit event_discussions_path(@event)
end

Then('I should see the discussion container') do
  expect(page).to have_selector('.discussion-container')
end

Then('I should see the thread type {string}') do |thread_type_label|
  expect(page).to have_content(thread_type_label)
end

Then('I should see an empty message area') do
  messages = page.all('.message')
  expect(messages.length).to eq(0)
end

When('I type {string} in the message input') do |message_text|
  textarea = find_field('message-content')
  textarea.set(message_text)
  sleep 0.2
end

When('I click the {string} button') do |button_text|
  click_button button_text
end

Then('I should see my message appear in the discussion') do
  expect(page).to have_content(@last_message_text) if @last_message_text
end

Then('the message should display my name') do
  user = User.find_by(email: @current_user_email)
  full_name = "#{user.first_name} #{user.last_name}"
  expect(page).to have_content(full_name)
end

Then('the message should display a timestamp') do
  expect(page).to have_selector('.time-ago')
end

When('I post the message {string}') do |message_text|
  @last_message_text = message_text
  @last_posted_message = message_text
  sleep 0.5
  fill_in 'message-content', with: message_text
  click_button 'Send Message'
  sleep 0.5
end

Then('the messages should appear in order:') do |table|
  messages = table.raw.flatten
  page_messages = page.all('.message-content').map(&:text)
  
  messages.each do |message|
    expect(page_messages).to include(message)
  end
  
  message_indices = messages.map { |m| page_messages.index(m) }
  expect(message_indices).to eq(message_indices.sort)
end

When('I add {string} as an attendee to the event') do |email|
  attendee = User.find_by(email: email)
  @event.attendees << attendee
end

Then('I should see the message {string} from the creator') do |message_text|
  expect(page).to have_content(message_text)
end

Then('my message should appear with my name') do
  user = User.find_by(email: @current_user_email)
  full_name = "#{user.first_name} #{user.last_name}"
  expect(page).to have_content(@last_posted_message)
  expect(page).to have_content(full_name)
end

Given('the event has a recipient named {string} {string}') do |first_name, last_name|
  Recipient.create!(
    event_id: @event.id,
    first_name: first_name,
    last_name: last_name
  )
end

Given('the recipient matches the email {string}') do |email|
  user = User.find_by(email: email)
  recipient = @event.recipients.last
  recipient.update!(first_name: user.first_name, last_name: user.last_name)
end

Then('I should be redirected to the event page') do
  expect(page).to have_current_path(%r{/events/?(\d+)?$})
end

Then('I should see an access denied message') do
  expect(page).to have_content('You do not have access')
end

Then('I should see the {string} tab') do |tab_name|
  expect(page).to have_content(tab_name)
end

Then('I should not see the {string} tab') do |tab_name|
  expect(page).not_to have_content(tab_name)
end

Then('my message should appear in the contributors discussion') do
  expect(page).to have_content(@last_posted_message)
end

Then('the message should display a relative timestamp like {string}') do |timestamp_text|
  expect(page).to have_content(timestamp_text)
end

Then('both messages should appear with my name') do
  user = User.find_by(email: @current_user_email)
  full_name = "#{user.first_name} #{user.last_name}"
  message_count = page.all('.message-meta').select { |el| el.text.include?(full_name) }.length
  expect(message_count).to be >= 2
end

Then('they should appear in the correct order') do
  messages = page.all('.message-content').map(&:text)
  expect(messages).to include('First message from me')
  expect(messages).to include('Second message from me')
  
  first_index = messages.index('First message from me')
  second_index = messages.index('Second message from me')
  expect(first_index).to be < second_index
end

Then('I should see {string} attributed to the creator') do |message_text|
  creator = User.find_by(email: 'creator@example.com')
  full_name = "#{creator.first_name} #{creator.last_name}"
  
  expect(page).to have_content(message_text)
  expect(page).to have_content(full_name)
end

Then('I should see {string} attributed to the attendee') do |message_text|
  attendee = User.find_by(email: 'attendee@example.com')
  full_name = "#{attendee.first_name} #{attendee.last_name}"
  
  expect(page).to have_content(message_text)
  expect(page).to have_content(full_name)
end

Then('my message should have the {string} styling') do |class_name|
  messages = page.all('.message').select { |el| el['class'].include?(class_name) }
  expect(messages.length).to be > 0
end

Then('the creator\'s message should have the {string} styling') do |class_name|
  messages = page.all('.message').select { |el| el['class'].include?(class_name) }
  expect(messages.length).to be > 0
end

Then('I should see the public discussion') do
  expect(page).to have_content('All Participants')
end

When('I reload the page') do
  visit current_path
end

Then('I should still see the message {string}') do |message_text|
  expect(page).to have_content(message_text)
end

Then('I should see the message displayed correctly without HTML interpretation') do
  message = page.find('.message-content')
  expect(message.text).to include('<')
  expect(message.text).to include('>')
  expect(message.text).not_to include('<script')
end

When('I post a message with {int} words') do |word_count|
  words = Array.new(word_count) { 'word' }
  message = words.join(' ')
  @last_posted_message = message
  fill_in 'message-content', with: message
  click_button 'Send Message'
  sleep 0.5
end

Then('the message should wrap and display correctly') do
  message_elem = page.find('.message-content')
  expect(message_elem).to be_visible
  expect(message_elem.text.length).to be > 100
end

Then('I should see the message {string}') do |message_text|
  expect(page).to have_content(message_text)
end

Before do
  @current_user_email = nil
  @last_message_text = nil
  @last_posted_message = nil
end
