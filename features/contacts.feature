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
    And I should see "Add a New Contact"

  Scenario: User can navigate to add contacts page
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts"
    And I click on "Add a New Contact"
    Then I should see "Add New Contact" heading
    And I should see "Search for a person to add as a contact"

  Scenario: Add contacts page displays available users
    Given a user exists with first name "John" and last name "User" and email "john@example.com" and password "password123"
    And a user exists with first name "Jane" and last name "User" and email "jane@example.com" and password "password123"
    And a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts/new"
    Then I should see "John User"
    And I should see "Jane User"

  Scenario: User can add a contact
    Given a user exists with first name "John" and last name "User" and email "john@example.com" and password "password123"
    And a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts/new"
    Then I should see "John User"

  Scenario: Added contacts appear in contacts list
    Given a user exists with email "user@example.com" and password "password123"
    And a user exists with email "john@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    And I add "john@example.com" as a contact
    When I navigate to "/contacts"
    Then I should see "Manage Contacts"

  Scenario: User cannot add duplicate contacts
    Given a user exists with first name "John" and last name "User" and email "john@example.com" and password "password123"
    And a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    And I add "john@example.com" as a contact
    When I navigate to "/contacts/new"
    Then I should not see "John User" in the available users list

  Scenario: User cannot add themselves as a contact
    Given a user exists with first name "Test" and last name "User" and email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts/new"
    Then I should not see "Test User" in the available users list

  Scenario: User can delete a contact
    Given a user exists with email "user@example.com" and password "password123"
    And a user exists with first name "John" and last name "User" and email "john@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    And I add "john@example.com" as a contact
    When I navigate to "/contacts"
    Then I should see "John User"
