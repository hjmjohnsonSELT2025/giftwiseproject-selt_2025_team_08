Feature: Gift Idea Generation
  As an event attendee or creator
  I want to generate gift ideas using AI
  So that I can get suggestions for what to gift to event recipients

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

  Scenario: Manually add a gift idea with price
    When I navigate to the event page
    And I select the recipient "John Doe"
    And I expand the "Manually Add Gift Idea" section
    And I enter "A high-quality mechanical watch" as the gift idea
    And I enter "$250" as the price
    And I click "Add Idea"
    Then the idea should appear in the "Saved Gift Ideas" section
    And the price should be saved

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
