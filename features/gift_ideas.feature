Feature: Gift Idea Generation
  As an event attendee or creator
  I want to generate gift ideas using AI
  So that I can get suggestions for what to gift to event recipients
  And I want to save product links and notes with my gift ideas

  Background:
    Given a user exists with email "creator@example.com" and password "password123"
    And a user exists with email "attendee@example.com" and password "password123"
    And I am signed in as "creator@example.com" with password "password123"
    And I have created an event named "Birthday Party" scheduled for "2025-12-15T18:00"
    And I have added a recipient to the event:
      | first_name | last_name | age | occupation | hobbies            |
      | John       | Doe       | 35  | Engineer   | Reading, Gaming    |

  Scenario: Generate gift ideas with price range
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Generate New Gift Ideas" section
    And I set the price range from "$50" to "$300"
    And I set the number of ideas to "5"
    And I click "Generate Ideas"
    Then I should see the "Generated Gift Ideas" section appear
    And I should see at least "5" gift ideas displayed

  Scenario: Save a generated gift idea
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Generate New Gift Ideas" section
    And I generate gift ideas
    And I click "Save for Later" on the first idea
    Then I should see a confirmation message "Idea saved for later!"
    And the idea should appear in the "Saved Gift Ideas" section

  Scenario: Manually add a gift idea with price, link, and note
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Manually Add Gift Idea" section
    And I enter "A high-quality mechanical watch" as the gift idea
    And I enter "$250" as the price
    And I enter "https://example.com/watch" as the product link
    And I enter "Great accuracy, leather strap" as the note
    And I click "Add Idea"
    Then the idea should appear in the "Saved Gift Ideas" section
    And the price should be saved
    And the link should be saved and clickable
    And the note should be saved and visible

  Scenario: Add a gift idea without link and note (optional fields)
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Manually Add Gift Idea" section
    And I enter "A basic gift" as the gift idea
    And I enter "$50" as the price
    And I click "Add Idea"
    Then the idea should appear in the "Saved Gift Ideas" section
    And the link field should be empty
    And the note field should be empty

  Scenario: Edit a saved gift idea with all fields
    Given I have saved the idea "Old idea" with price "$50" and link "https://old.com" and note "Old note" for "John Doe"
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Saved Gift Ideas" section
    And I click "Edit" on "Old idea"
    And the edit modal opens
    And I change the idea to "New idea"
    And I change the price to "$100"
    And I change the link to "https://new.com"
    And I change the note to "New note"
    And I save the edited gift idea
    Then I should see a confirmation message "Idea updated!"
    And the idea should be updated in the "Saved Gift Ideas" section
    And the new information should be persisted

  Scenario: Edit a saved gift idea and clear the link
    Given I have saved the idea "Product" with link "https://example.com" for "John Doe"
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I click "Edit" on "Product"
    And I clear the link field
    And I save the edited gift idea
    Then the link should no longer be displayed for "Product"

  Scenario: Edit a saved gift idea and clear the note
    Given I have saved the idea "Item" with note "Important note" for "John Doe"
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I click "Edit" on "Item"
    And I clear the note field
    And I save the edited gift idea
    Then the note should no longer be displayed for "Item"

  Scenario: Note field enforces 255 character limit
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Manually Add Gift Idea" section
    And I enter "A gift" as the gift idea
    And I enter a note with more than 255 characters
    Then the note should be truncated to 255 characters
    And the character counter should show "255/255"

  Scenario: Invalid URL is rejected
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Manually Add Gift Idea" section
    And I enter "A gift" as the gift idea
    And I enter "not a valid url" as the product link
    And I click "Add Idea"
    Then I should see an error message about the invalid URL
    And the idea should not be saved

  Scenario: Unfavorite a saved idea
    Given I have already saved an idea "Wireless headphones" for "John Doe"
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Saved Gift Ideas" section
    Then I should see "Wireless headphones" in the saved ideas
    When I click "Unfavorite" on "Wireless headphones"
    Then the idea should no longer appear in the "Saved Gift Ideas" section

  Scenario: Different attendees have separate gift ideas
    Given the attendee "attendee@example.com" is added to the event
    And I have saved the idea "Book" for "John Doe"
    When I sign out
    And I sign in as "attendee@example.com" with password "password123"
    And I navigate to the event page
    And I select the recipient "John Doe"
    Then I should not see "Book" in the saved ideas
    When I save a different idea "Gaming Headset" for "John Doe"
    And I sign out
    And I sign in as "creator@example.com" with password "password123"
    And I navigate to the event page
    And I select the recipient "John Doe"
    Then I should see "Book" but not "Gaming Headset" in the saved ideas

  Scenario: Record a gift as given to recipient
    Given I have saved the idea "A watch" for "John Doe"
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Saved Gift Ideas" section
    And I click "Add as Gift" on "A watch"
    Then I should see a confirmation message "Gift added!"
    And "A watch" should appear in the "Previous Gifts" section
    And the current gift displayed under "John Doe" should be "A watch"

  Scenario: Previous gifts show only user's recorded gifts
    Given I have recorded a gift "Book" for "John Doe"
    And the attendee "attendee@example.com" has recorded a gift "Watch" for "John Doe"
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Previous Gifts" section
    Then I should only see "Book" in the previous gifts
    And I should not see "Watch" in the previous gifts

  Scenario: Edit a previous gift idea
    Given I have recorded a gift "Book" with price "$30" for "John Doe"
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Previous Gifts" section
    And I click "Edit" on "Book"
    And I change the idea to "Updated Book Title"
    And I change the price to "$35"
    And I save the edited gift idea
    Then the gift should be updated with the new information
    And the updated gift should appear in the "Previous Gifts" section