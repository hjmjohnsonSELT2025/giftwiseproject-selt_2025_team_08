Feature: Contacts Management
  As a signed-in user
  I want to view and manage my contacts
  So that I can keep track of people for gift giving

  Scenario: User cannot access contacts without signing in
    When I navigate to "/contacts"
    Then I should be redirected to the login page

  Scenario: Authenticated user can access contacts page
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts"
    Then I should see "Contacts"

  Scenario: Contacts page displays search functionality
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts"
    Then I should see the search bar
    And I should see "Add Contact" button
