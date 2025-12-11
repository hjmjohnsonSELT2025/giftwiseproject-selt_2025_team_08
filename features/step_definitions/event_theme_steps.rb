Given('I have created an event named {string} scheduled for {string} with theme {string}') do |event_name, scheduled_time, theme|
  @user = User.find_by(email: 'creator@example.com')
  parsed_time = DateTime.parse(scheduled_time)
  @event = Event.create!(
    name: event_name,
    description: "Test event: #{event_name}",
    start_at: parsed_time,
    end_at: parsed_time + 2.hours,
    creator_id: @user.id,
    theme: theme
  )
end

Then('I should see the theme field') do
  expect(page).to have_select('event_theme')
end

Then('I should see {string} on the event page') do |text|
  if text.start_with?('Theme: ')
    theme_value = text.gsub('Theme: ', '')
    expect(page).to have_content('Theme')
    expect(page).to have_content(theme_value)
  else
    expect(page).to have_content(text)
  end
end

When('I navigate to view the event theme details') do
  visit event_path(@event)
end

When('I change the theme to {string}') do |new_theme|
  select new_theme, from: 'event_theme'
end

When('I click save') do
  click_button 'Save Event' rescue click_button 'Update' rescue find('button[type="submit"]').click
end

Then('the event theme should be updated to {string}') do |theme|
  @event.reload
  expect(@event.theme).to eq(theme)
  visit event_path(@event)
  expect(page).to have_content('Theme')
  expect(page).to have_content(theme)
end

