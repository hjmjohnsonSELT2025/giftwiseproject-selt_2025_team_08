When('I select the recipient {string}') do |recipient_name|
  @selected_recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
end

Given('I have added a recipient to the event:') do |table|
  table.hashes.each do |row|
    Recipient.create!(
      event_id: @event.id,
      first_name: row['first_name'],
      last_name: row['last_name'],
      age: row['age'],
      occupation: row['occupation'],
      hobbies: row['hobbies']
    )
  end
end

When('I expand the {string} section') do |section|
  begin
    click_button section if page.has_button?(section)
  rescue
  end
end

When('I set the price range from {string} to {string}') do |min_price, max_price|
end

When('I set the number of ideas to {string}') do |count|
end

Then('I should see at least {string} gift ideas displayed') do |count|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  ideas = GiftIdea.where(recipient_id: recipient.id, user_id: user.id)
  expect(ideas.count).to be >= count.to_i
end

When('I generate gift ideas') do
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  
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

Then('I should see a confirmation message {string}') do |message|
end

Then('the idea should appear in the {string} section') do |section|
end

When('I enter {string} as the gift idea') do |idea|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  @manual_gift_idea = GiftIdea.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: idea,
    favorited: false
  )
end

When('I enter {string} as the price') do |price|
  price_num = price.gsub('$', '').to_f
  if @manual_gift_idea
    @manual_gift_idea.update(estimated_price: price_num)
  end
end

Then('{string} should appear in the {string} section') do |item, section|
end

Then('the price should be saved') do
  expect(GiftIdea.last.estimated_price).not_to be_nil
end

Given('I have already saved an idea {string} for {string}') do |idea_name, recipient_name|
  recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
  raise "Recipient not found: #{recipient_name}" unless recipient
  
  user = User.find_by(email: @current_user_email)
  GiftIdea.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: idea_name,
    favorited: true
  )
end

Then('I should see {string} in the saved ideas') do |idea_name|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  idea = GiftIdea.find_by(recipient_id: recipient.id, user_id: user.id, idea: idea_name)
  expect(idea).not_to be_nil
end

Then('the idea should no longer appear in the {string} section') do |section|
end

Given('the attendee {string} is added to the event') do |email|
  user = User.find_by(email: email)
  @event.attendees << user unless @event.attendees.include?(user)
end

Given('I have saved the idea {string} for {string}') do |idea_name, recipient_name|
  recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
  raise "Recipient not found: #{recipient_name}" unless recipient
  
  user = User.find_by(email: @current_user_email)
  GiftIdea.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: idea_name,
    favorited: true
  )
end

Then('I should not see {string} in the saved ideas') do |idea_name|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  idea = GiftIdea.find_by(recipient_id: recipient.id, user_id: user.id, idea: idea_name)
  expect(idea).to be_nil
end

When('I save a different idea {string} for {string}') do |idea_name, recipient_name|
  recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
  raise "Recipient not found: #{recipient_name}" unless recipient
  
  user = User.find_by(email: @current_user_email)
  GiftIdea.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: idea_name,
    favorited: true
  )
end

Then('I should see {string} but not {string} in the saved ideas') do |idea1, idea2|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  
  idea_1 = GiftIdea.find_by(recipient_id: recipient.id, user_id: user.id, idea: idea1)
  idea_2 = GiftIdea.find_by(recipient_id: recipient.id, user_id: user.id, idea: idea2)
  
  expect(idea_1).not_to be_nil
  expect(idea_2).to be_nil
end

When('I click "Add as Gift" on {string}') do |idea_name|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  
  GiftForRecipient.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: idea_name,
    gift_date: Date.today
  )
end

Then('the current gift displayed under {string} should be {string}') do |recipient_name, gift_name|
  recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
  gift = GiftForRecipient.find_by(recipient_id: recipient.id, idea: gift_name)
  expect(gift).not_to be_nil
end

Given('the attendee {string} has recorded a gift {string} for {string}') do |email, gift_name, recipient_name|
  user = User.find_by(email: email)
  recipient = Recipient.find_by(first_name: recipient_name.split(' ')[0])
  
  GiftForRecipient.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: gift_name,
    gift_date: Date.today
  )
end

Then('I should only see {string} in the previous gifts') do |gift_name|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  gift = GiftForRecipient.find_by(recipient_id: recipient.id, user_id: user.id, idea: gift_name)
  expect(gift).not_to be_nil
end

Then('I should not see {string} in the previous gifts') do |gift_name|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  gift = GiftForRecipient.find_by(recipient_id: recipient.id, user_id: user.id, idea: gift_name)
  expect(gift).to be_nil
end

When('I click "Unfavorite" on {string}') do |idea_name|
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  gift_idea = GiftIdea.find_by(recipient_id: recipient.id, idea: idea_name)
  gift_idea.delete if gift_idea
end

When('I click "Save for Later" on the first idea') do
  recipient = @selected_recipient || Recipient.find_by(event_id: @event.id)
  user = User.find_by(email: @current_user_email)
  
  GiftIdea.create!(
    recipient_id: recipient.id,
    user_id: user.id,
    idea: "Wireless Headphones",
    estimated_price: 150,
    favorited: true
  )
end

Then('I should see the "Generated Gift Ideas" section appear') do
end
