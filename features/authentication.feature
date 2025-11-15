Feature: User Authentication
  As a user
  I want to sign up and sign in to the application
  So that I can access my account

  Scenario: User successfully signs up
    When I navigate to "/registrations/new"
    Then I should see the registration page
    When I fill in "user_email" with "newuser@example.com"
    And I fill in "user_password" with "Password123!"
    And I fill in "user_password_confirmation" with "Password123!"
    And I fill in "user_first_name" with "John"
    And I fill in "user_last_name" with "Doe"
    And I fill in "user_date_of_birth" with "1990-01-15"
    And I select "Male" from "user_gender"
    And I fill in "user_occupation" with "Software Engineer"
    And I fill in "user_street" with "123 Main St"
    And I fill in "user_city" with "Springfield"
    And I fill in "user_state" with "IL"
    And I fill in "user_country" with "USA"
    And I fill in "user_zip_code" with "62701"
    And I click "Sign up"
    Then I should see "Account created successfully"
    And I should be on the login page

  Scenario: User successfully signs in
    Given a user exists with email "user@example.com" and password "password123"
    When I navigate to "/login"
    Then I should see the login page
    When I fill in "email" with "user@example.com"
    And I fill in "password" with "password123"
    And I click "Log in"
    Then I should see "Signed in successfully"

  Scenario: User sees error with invalid credentials
    When I navigate to "/login"
    And I fill in "email" with "nonexistent@example.com"
    And I fill in "password" with "wrongpassword"
    And I click "Log in"
    Then I should see "Invalid email or password"

  Scenario: User successfully signs out
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"
    When I click "Logout"
    Then I should see "Signed out successfully"

  Scenario: User cannot access settings without signing in
    When I navigate to "/settings"
    Then I should be redirected to the login page
