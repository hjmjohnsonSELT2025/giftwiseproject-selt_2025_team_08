Feature: Event Discussion Management
  As an event participant
  I want to discuss event details in dedicated threads
  So that I can collaborate with other participants

  Background:
    Given a user exists with email "creator@example.com" and password "password123"
    And a user exists with email "attendee@example.com" and password "password123"
    And a user exists with email "recipient@example.com" and password "password123"
    And I am signed in as "creator@example.com" with password "password123"
    And I have created an event named "Team Lunch" scheduled for "2025-12-20T12:00"

  Scenario: View public discussion thread
    When I navigate to the event discussions page with thread type "public"
    Then I should see the discussion container
    And I should see the thread type "All Participants"
    And I should see an empty message area

  Scenario: View contributors only discussion thread as creator
    When I navigate to the event discussions page with thread type "contributors_only"
    Then I should see the discussion container
    And I should see the thread type "Contributors Only"
    And I should see an empty message area

  Scenario: Post a message to public discussion
    When I navigate to the event discussions page with thread type "public"
    And I type "Let's meet at the restaurant" in the message input
    And I click the "Send Message" button
    Then I should see my message appear in the discussion
    And the message should display my name
    And the message should display a timestamp

  Scenario: View posted messages in order
    When I navigate to the event discussions page with thread type "public"
    And I post the message "First message"
    And I post the message "Second message"
    And I post the message "Third message"
    Then the messages should appear in order:
      | First message   |
      | Second message  |
      | Third message   |

  Scenario: Attendee can post to public discussion
    When I add "attendee@example.com" as an attendee to the event
    And I sign out
    And I am signed in as "attendee@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "public"
    Then I should see the discussion container

  Scenario: Recipient can view public discussion
    Given the event has a recipient named "John" "Doe"
    And the recipient matches the email "recipient@example.com"
    When I sign out
    And I am signed in as "recipient@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "public"
    Then I should see the discussion container

  Scenario: Recipient cannot view contributors only discussion
    Given the event has a recipient named "John" "Doe"
    And the recipient matches the email "recipient@example.com"
    When I sign out
    And I am signed in as "recipient@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "contributors_only"
    Then I should be redirected to the event page
    And I should see an access denied message

  Scenario: Non-participant cannot access discussion
    Given a user exists with email "stranger@example.com" and password "password123"
    When I sign out
    And I am signed in as "stranger@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "public"
    Then I should be redirected to the event page
    And I should see an access denied message

  Scenario: Creator and attendee see contributors only thread tab
    When I add "attendee@example.com" as an attendee to the event
    And I navigate to the event discussions page with thread type "public"
    Then I should see the "Contributors Only" tab
    And I sign out
    And I am signed in as "attendee@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "public"
    Then I should see the "Contributors Only" tab

  Scenario: Recipient does not see contributors only thread tab
    Given the event has a recipient named "Jane" "Smith"
    And the recipient matches the email "recipient@example.com"
    When I sign out
    And I am signed in as "recipient@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "public"
    Then I should not see the "Contributors Only" tab

  Scenario: Post message to contributors only discussion
    When I add "attendee@example.com" as an attendee to the event
    And I navigate to the event discussions page with thread type "contributors_only"
    And I post the message "Contributors can discuss this privately"
    Then my message should appear in the contributors discussion
    And I sign out
    And I am signed in as "attendee@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "contributors_only"
    And I should see the message "Contributors can discuss this privately"

  Scenario: Message timestamps display correctly
    When I navigate to the event discussions page with thread type "public"
    And I post the message "Timestamped message"
    Then the message should display a relative timestamp like "less than a minute ago"

  Scenario: Multiple messages from same user
    When I navigate to the event discussions page with thread type "public"
    And I post the message "First message from me"
    And I post the message "Second message from me"
    Then both messages should appear with my name
    And they should appear in the correct order

  Scenario: Messages from different users display correctly
    When I navigate to the event discussions page with thread type "public"
    And I post the message "Creator's message"
    And I add "attendee@example.com" as an attendee to the event
    And I sign out
    And I am signed in as "attendee@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "public"
    And I post the message "Attendee's message"
    Then I should see "Creator's message" attributed to the creator
    And I should see "Attendee's message" attributed to the attendee

  Scenario: Own messages are visually distinguished
    When I navigate to the event discussions page with thread type "public"
    And I post the message "My own message"
    Then my message should have the "own-message" styling
    And I add "attendee@example.com" as an attendee to the event
    And I sign out
    And I am signed in as "attendee@example.com" with password "password123"
    And I navigate to the event discussions page with thread type "public"
    And I post the message "Attendee's message"
    Then the creator's message should have the "other-message" styling

  Scenario: Default to public thread when no type specified
    When I navigate to the event discussions page without specifying thread type
    Then I should see the public discussion

  Scenario: Discussion persists after page reload
    When I navigate to the event discussions page with thread type "public"
    And I post the message "Message that persists"
    And I reload the page
    Then I should still see the message "Message that persists"

  Scenario: Special characters in messages are handled correctly
    When I navigate to the event discussions page with thread type "public"
    And I post the message "Message with special chars: <>&\"'"
    Then I should see the message displayed correctly without HTML interpretation

  Scenario: Long messages are displayed properly
    When I navigate to the event discussions page with thread type "public"
    And I post a message with 200 words
    Then the message should wrap and display correctly
