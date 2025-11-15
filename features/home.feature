Feature: Home Page
  As a user
  I want to see a home page
  So that I can access the application

  Scenario: Unauthenticated user is redirected to login
    When I navigate to "/"
    Then I should be redirected to the login page

  Scenario: Authenticated user sees home page
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/"
    Then I should see "Welcome to Gift Wise"
    And I should see "Test"

  Scenario: Authenticated user can access navigation
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/"
    Then the page should have links for authenticated user
