Feature: Event Attendees Management
  As an event creator
  I want to invite attendees to my events
  So that they can collaborate on gift planning

  Background:
    Given a user exists with email "creator@example.com" and password "password123"
    And a user exists with email "attendee1@example.com" and password "password123"
    And a user exists with email "attendee2@example.com" and password "password123"
    And I am signed in as "creator@example.com" with password "password123"
    And I have created an event named "Birthday Party" scheduled for "2025-12-15T18:00"

  Scenario: Add an attendee to an event
    When I navigate to the edit event page
    And I click on the attendee search field
    And I search for contacts to add as attendees
    And I select "attendee1@example.com" as an attendee
    Then "attendee1@example.com" should be listed as an attendee
    And they should receive access to the event

  Scenario: Multiple attendees can attend the same event
    When I navigate to the edit event page
    And I add the following attendees from my contacts:
      | email                |
      | attendee1@example.com |
      | attendee2@example.com |
    Then both attendees should be listed on the event
    And both should have access to the event details

  Scenario: Prevent duplicate attendees
    Given "attendee1@example.com" is already an attendee of the event
    When I navigate to the edit event page
    And I try to add "attendee1@example.com" again as an attendee
    Then I should see an error about duplicate attendees
    And "attendee1@example.com" should only appear once

  Scenario: Creator is automatically an attendee
    When I create a new event named "Another Party" scheduled for "2025-12-20T18:00"
    And I navigate to view the event
    Then I should see myself listed as an attendee
    And I should have full access to gift planning sections

  Scenario: Remove an attendee from an event
    Given "attendee1@example.com" is an attendee of the event
    When I navigate to the edit event page
    And I click the remove button for "attendee1@example.com"
    Then "attendee1@example.com" should no longer be listed as an attendee
    And they should lose access to the event

  Scenario: Attendee can view event details
    Given "attendee1@example.com" is an attendee of the event
    When I sign out
    And I sign in as "attendee1@example.com" with password "password123"
    And I navigate to my events page
    Then I should see "Birthday Party" listed
    When I click on the event
    Then I should see the event details and recipients

  Scenario: Attendee cannot edit event details
    Given "attendee1@example.com" is an attendee of the event
    When I sign out
    And I sign in as "attendee1@example.com" with password "password123"
    And I navigate to my events page
    And I view the "Birthday Party" event
    Then I should not see an "Edit" button for the event

  Scenario: Only creator can add or remove attendees
    Given "attendee1@example.com" is an attendee of the event
    When I sign out
    And I sign in as "attendee1@example.com" with password "password123"
    And I try to add "attendee2@example.com" as an attendee
    Then I should receive a "Forbidden" error
    And "attendee2@example.com" should not be added to the event
