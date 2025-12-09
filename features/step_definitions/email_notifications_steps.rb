Then('event reminders should be enabled for this user') do
  user = User.find_by(email: 'user@example.com')
  expect(user.email_notification_preference.event_reminders_enabled).to be true
end

Then('event reminders should be disabled for this user') do
  user = User.find_by(email: 'user@example.com')
  expect(user.email_notification_preference.event_reminders_enabled).to be false
end

Then('gift reminders should be enabled for this user') do
  user = User.find_by(email: 'user@example.com')
  expect(user.email_notification_preference.gift_reminders_enabled).to be true
end

Then('gift reminders should be disabled for this user') do
  user = User.find_by(email: 'user@example.com')
  expect(user.email_notification_preference.gift_reminders_enabled).to be false
end

Then('event reminder timing should be set to {string}') do |timing|
  user = User.find_by(email: 'user@example.com')
  expect(user.email_notification_preference.event_reminder_timing).to eq(timing)
end

Then('gift reminder timing should be set to {string}') do |timing|
  user = User.find_by(email: 'user@example.com')
  expect(user.email_notification_preference.gift_reminder_timing).to eq(timing)
end

Given('an event {string} exists starting {string} from now') do |event_name, time_offset|
  user = User.find_by(email: 'user@example.com')
  time_hash = parse_time_offset(time_offset)
  start_time = Time.current + time_hash[:value].send(time_hash[:unit])
  end_time = start_time + 1.hour

  @event = Event.create!(
    name: event_name,
    description: "Test event: #{event_name}",
    start_at: start_time,
    end_at: end_time,
    location: 'Test Location',
    creator_id: user.id,
    theme: 'General'
  )
end

Given('the event has {string} recipients') do |count|
  count.to_i.times do |i|
    Recipient.create!(
      event_id: @event.id,
      first_name: "Recipient",
      last_name: "#{i + 1}"
    )
  end
end

Given('I am an attendee of the event') do
  user = User.find_by(email: 'user@example.com')
  @event.attendees << user unless @event.attendees.include?(user)
end

Given('I have event reminders enabled with {string} timing') do |timing_display|
  user = User.find_by(email: 'user@example.com')
  timing_key = timing_display_to_key(timing_display)
  
  preference = user.email_notification_preference || user.build_email_notification_preference
  preference.event_reminders_enabled = true
  preference.event_reminder_timing = timing_key
  preference.save!
end

Given('I have gift reminders enabled with {string} timing') do |timing_display|
  user = User.find_by(email: 'user@example.com')
  timing_key = timing_display_to_key(timing_display)
  
  preference = user.email_notification_preference || user.build_email_notification_preference
  preference.gift_reminders_enabled = true
  preference.gift_reminder_timing = timing_key
  preference.save!
end

Given('I have event reminders disabled') do
  user = User.find_by(email: 'user@example.com')
  preference = user.email_notification_preference || user.build_email_notification_preference
  preference.event_reminders_enabled = false
  preference.save!
end

Given('I have gift reminders disabled') do
  user = User.find_by(email: 'user@example.com')
  preference = user.email_notification_preference || user.build_email_notification_preference
  preference.gift_reminders_enabled = false
  preference.save!
end

Given('a reminder has already been sent for this event') do
  user = User.find_by(email: 'user@example.com')
  SentReminder.create!(
    user_id: user.id,
    event_id: @event.id,
    reminder_type: 'event',
    timing: 'day_before'
  )
end

When('the notification job runs') do
  CheckNotificationsJob.perform_now
end

Then('an event reminder email should be sent to {string}') do |email|
  expect(ActionMailer::Base.deliveries.count).to be > 0
  
  event_emails = ActionMailer::Base.deliveries.select do |mail|
    mail.to.include?(email) && mail.subject.include?('Reminder:')
  end
  
  expect(event_emails).not_to be_empty
end

Then('an event reminder email should be sent') do
  expect(ActionMailer::Base.deliveries.count).to be > 0
  
  event_emails = ActionMailer::Base.deliveries.select do |mail|
    mail.subject.include?('Reminder:')
  end
  
  expect(event_emails).not_to be_empty
end

Then('a gift reminder email should be sent to {string}') do |email|
  expect(ActionMailer::Base.deliveries.count).to be > 0
  
  gift_emails = ActionMailer::Base.deliveries.select do |mail|
    mail.to.include?(email) && mail.subject.include?('Gift Reminder:')
  end
  
  expect(gift_emails).not_to be_empty
end

Then('no event reminder email should be sent') do
  event_emails = ActionMailer::Base.deliveries.select do |mail|
    mail.subject.include?('Reminder:')
  end
  
  expect(event_emails).to be_empty
end

Then('the email subject should contain {string}') do |text|
  email = ActionMailer::Base.deliveries.last
  expect(email.subject).to include(text)
end

Then('the email should list {string} recipients') do |count|
  email = ActionMailer::Base.deliveries.last
  expect(email.body.encoded).to include(count.to_i.to_s)
end

Then('a gift reminder email should be sent') do
  expect(ActionMailer::Base.deliveries.count).to be > 0
  
  gift_emails = ActionMailer::Base.deliveries.select do |mail|
    mail.subject.include?('Gift Reminder:')
  end
  
  expect(gift_emails).not_to be_empty
end

Then('the email should contain {string}') do |text|
  email = ActionMailer::Base.deliveries.last
  expect(email.body.encoded).to include(text)
end

Then('the email should contain gift suggestions for the recipient') do
  email = ActionMailer::Base.deliveries.last
  body = email.body.encoded
  expect(body).to match(/suggestion|idea/i)
end

Given('an event {string} exists with the following details:') do |event_name, table|
  user = User.find_by(email: 'user@example.com')
  attributes = { name: event_name, creator_id: user.id }
  
  table.hashes.each do |row|
    attributes[row['field'].to_sym] = row['value']
  end
  
  attributes[:start_at] ||= 1.day.from_now
  attributes[:end_at] ||= attributes[:start_at] + 1.hour
  attributes[:location] ||= 'Test Location'
  attributes[:theme] ||= 'General'
  
  @event = Event.create!(attributes)
end

Given('the event starts {string} from now') do |time_offset|
  time_hash = parse_time_offset(time_offset)
  start_time = Time.current + time_hash[:value].send(time_hash[:unit])
  
  @event.update!(
    start_at: start_time,
    end_at: start_time + 1.hour
  )
end

def parse_time_offset(offset_string)
  parts = offset_string.downcase.split
  value = parts[0].to_i
  unit = parts[1]
  
  case unit
  when 'day', 'days'
    { value: value, unit: 'days' }
  when 'week', 'weeks'
    { value: value, unit: 'weeks' }
  when 'month', 'months'
    { value: value, unit: 'months' }
  when 'hour', 'hours'
    { value: value, unit: 'hours' }
  else
    { value: 1, unit: 'days' }
  end
end

def timing_display_to_key(display)
  {
    'At time of event' => 'at_time',
    'Day of Event' => 'day_of',
    'Day Before' => 'day_before',
    '2 Days Before' => 'two_days_before',
    'Week Before' => 'week_before',
    '2 Weeks Before' => 'two_weeks_before',
    'A Month Before' => 'month_before',
    'two_weeks_before' => 'two_weeks_before',
    'week_before' => 'week_before',
    'month_before' => 'month_before'
  }[display] || display
end
