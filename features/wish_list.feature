Feature: Wish List Management
  As a signed-in user
  I want to manage my personal wish list
  So that others can see what gifts I would like to receive

  Scenario: User cannot access wish list without signing in
    When I navigate to "/wish_list_items"
    Then I should be redirected to the login page

  Scenario: Authenticated user can access wish list page
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/wish_list_items"
    Then I should see "Wish List"

  Scenario: Wish list page displays empty message when no items
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/wish_list_items"
    Then I should see "0/10 items added"

  Scenario: User can add a new wish list item
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/wish_list_items"
    And I click on "Add Item"
    Then I should see "Name"
    When I fill in "wish_list_item_name" with "New Item"
    And I submit the form
    Then I should see "Wish List"

  Scenario: User can add up to 10 wish list items
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    And the user has 10 wish list items
    When I navigate to "/wish_list_items"
    Then I should see "10/10 items added"

  Scenario: Navigation tab links to wish list
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to the home page
    Then I should see "Wish List" in the navigation
