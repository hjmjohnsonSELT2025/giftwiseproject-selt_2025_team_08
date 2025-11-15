Feature: User Settings
  As a signed-in user
  I want to manage my account settings
  So that I can keep my profile information up to date

  Scenario: User views settings page
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/settings"
    Then I should see "Account Settings" or settings form elements

  Scenario: User cannot access settings without authentication
    When I navigate to "/settings"
    Then I should be redirected to the login page

  Scenario: Authenticated user can see their profile
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I navigate to "/settings"
    Then I should see form fields for profile information
