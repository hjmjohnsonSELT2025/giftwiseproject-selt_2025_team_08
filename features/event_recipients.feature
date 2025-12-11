Feature: Event Recipients Management
  As an event creator
  I want to manage recipients for my events
  So that attendees can plan gifts for the right people

  Background:
    Given a user exists with email "creator@example.com" and password "password123"
    And a user exists with email "attendee@example.com" and password "password123"
    And I am signed in as "creator@example.com" with password "password123"
    And I have created an event named "Birthday Party" scheduled for "2025-12-15T18:00"

  Scenario: Add a recipient to an event
    When I navigate to the event page
    Then I should see the "Recipients & Gifts" section

  Scenario: Add multiple recipients to an event
    When I navigate to the edit event page
    And I add the following recipients:
      | name      | age | occupation |
      | John Doe  | 35  | Engineer   |
      | Jane Smith | 32 | Doctor     |
      | Bob Jones | 28  | Teacher    |
    Then all "3" recipients should be listed on the event edit page

  Scenario: Remove a recipient from an event
    Given the event has a recipient "John Doe"
    When I navigate to the edit event page
    And I click the remove button for recipient "John Doe"
    Then "John Doe" should no longer appear on the event edit page
    And the recipient should be deleted from the database

  Scenario: Prevent duplicate recipients
    Given the event already has a recipient "John Doe"
    When I navigate to the edit event page
    And I try to add "John Doe" again as a recipient
    Then I should see an error message about duplicate recipients
    And "John Doe" should only appear once on the event

  Scenario: Recipients appear on event show page
    Given the event has recipients:
      | first_name | last_name | age | occupation |
      | John       | Doe       | 35  | Engineer   |
      | Jane       | Smith     | 32  | Doctor     |
    When I navigate to the event page
    Then I should see the "Recipients & Gifts" section
    And I should see "John Doe" and "Jane Smith" listed as recipients

  Scenario: Current gift displays under recipient
    Given the event has a recipient "John Doe"
    And I have recorded a gift "Wireless Headphones" for "John Doe"
    When I navigate to the event page
    Then under "John Doe" I should see the current gift "Wireless Headphones"

  Scenario: Recipients cannot see gift planning sections
    Given the event has a recipient "John Doe"
    And I have added "attendee@example.com" as an attendee to the event
    And I sign out
    And I am not associated with the event in any way except as the recipient "John Doe"
    When I navigate to the event page
    Then I should not see the "Recipients & Gifts" section
    And I should not see the "Generate New Gift Ideas" section
    And I should only see the event description and discussion thread

  Scenario: Creator can add attendees from contacts
    When I navigate to the event page
    Then I should see the "Recipients & Gifts" section
