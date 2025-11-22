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

  Scenario: User can navigate to add contacts page
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts"
    And I click on "Add Contact"
    Then I should see "Add Contact" heading
    And I should see "Search for a person to add as a contact"

  Scenario: Add contacts page displays available users
    Given a user exists with email "user@example.com" and password "password123"
    And a user exists with email "john@example.com" and password "password123"
    And a user exists with email "jane@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts/new"
    Then I should see "john@example.com"
    And I should see "jane@example.com"

  Scenario: User can add a contact
    Given a user exists with email "user@example.com" and password "password123"
    And a user exists with email "john@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts/new"
    And I click the "Add Contact" button for "john@example.com"
    Then I should be on the contacts page
    And I should see "Contact added successfully"

  Scenario: Added contacts appear in contacts list
    Given a user exists with email "user@example.com" and password "password123"
    And a user exists with email "john@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    And I add "john@example.com" as a contact
    When I navigate to "/contacts"
    Then I should see the contact with email "john@example.com" in the table

  Scenario: User cannot add duplicate contacts
    Given a user exists with email "user@example.com" and password "password123"
    And a user exists with email "john@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    And I add "john@example.com" as a contact
    When I navigate to "/contacts/new"
    Then I should not see "john@example.com" in the available users list

  Scenario: User cannot add themselves as a contact
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/contacts/new"
    Then I should not see my own email in the available users list

  Scenario: User can delete a contact
    Given a user exists with email "user@example.com" and password "password123"
    And a user exists with email "john@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    And I add "john@example.com" as a contact
    When I navigate to "/contacts"
    And I delete the contact with email "john@example.com"
    Then I should see "Contact removed successfully"
    And I should not see "john@example.com" in the contacts table
