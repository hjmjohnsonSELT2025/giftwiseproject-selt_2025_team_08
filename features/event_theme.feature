Feature: Event Theme Management
  As an event creator
  I want to assign themes to events
  So that I can categorize my gift occasions

  Background:
    Given a user exists with email "creator@example.com" and password "password123"
    And I am signed in as "creator@example.com" with password "password123"

  Scenario: User can select a theme when creating an event
    When I navigate to "/events/new"
    Then I should see the new event form
    And I should see the theme field

  Scenario: Theme is displayed on the event details page
    Given I have created an event named "Birthday Party" scheduled for "2025-12-15T18:00" with theme "Birthday"
    When I navigate to view the event theme details
    Then I should see "Theme: Birthday" on the event page

  Scenario: Theme can be edited on an existing event
    Given I have created an event named "Party" scheduled for "2025-12-15T18:00" with theme "Birthday"
    When I navigate to the edit event page
    And I change the theme to "Anniversary"
    And I click save
    Then the event theme should be updated to "Anniversary"

  Scenario: All attendees can see the theme
    Given I have created an event named "Birthday Party" scheduled for "2025-12-15T18:00" with theme "Wedding"
    And a user exists with email "attendee@example.com" and password "password123"
    And "attendee@example.com" is an attendee of the event
    When I sign out
    And I am signed in as "attendee@example.com" with password "password123"
    And I navigate to the event page
    Then I should see "Theme: Wedding" on the event page

