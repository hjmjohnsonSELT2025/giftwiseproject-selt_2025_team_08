Feature: Events Management
  As a signed-in user
  I want to view my events
  So that I can manage my gift occasions

  Scenario: User cannot access events without signing in
    When I navigate to "/events"
    Then I should be redirected to the login page

  Scenario: Authenticated user can access events page
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/events"
    Then I should see "Events"

  Scenario: User can create a new event
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/events/new"
    Then I should see the new event form
