Feature: Email Notifications
  As a user
  I want to receive email reminders for upcoming events and gift tasks
  So that I don't forget important events or gifts to purchase

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am signed in as "user@example.com" with password "password123"

  Scenario: Event reminder is sent when event is upcoming
    Given an event "Team Building Day" exists starting "1 day" from now
    And the event has "2" recipients
    And I am an attendee of the event
    And I have event reminders enabled with "Day Before" timing
    When the notification job runs
    Then an event reminder email should be sent to "user@example.com"
    And the email subject should contain "Team Building Day"
    And the email should list "2" recipients

  Scenario: Gift reminder is sent when event is upcoming
    Given an event "Birthday Party" exists starting "7 days" from now
    And the event has "1" recipients
    And I am an attendee of the event
    And I have gift reminders enabled with "Week Before" timing
    When the notification job runs
    Then a gift reminder email should be sent to "user@example.com"
    And the email subject should contain "Birthday Party"

  Scenario: No reminder is sent when reminders are disabled
    Given an event "Anniversary" exists starting "1 day" from now
    And the event has "1" recipients
    And I am an attendee of the event
    And I have event reminders disabled
    When the notification job runs
    Then no event reminder email should be sent

  Scenario: Duplicate reminders are not sent
    Given an event "Graduation" exists starting "1 day" from now
    And the event has "1" recipients
    And I am an attendee of the event
    And I have event reminders enabled with "Day Before" timing
    And a reminder has already been sent for this event
    When the notification job runs
    Then no event reminder email should be sent

  Scenario: Different timing options trigger reminders appropriately
    Given an event "Wedding" exists starting "2 days" from now
    And the event has "3" recipients
    And I am an attendee of the event
    When I have event reminders enabled with "2 Days Before" timing
    And the notification job runs
    Then an event reminder email should be sent to "user@example.com"

  Scenario: Email contains all event details
    Given an event "Retirement Party" exists with the following details:
      | field       | value                  |
      | theme       | Retirement             |
      | location    | Conference Room A      |
      | description | Celebrating John Smith |
    And the event starts "1 day" from now
    And the event has "2" recipients
    And I am an attendee of the event
    And I have event reminders enabled with "Day Before" timing
    When the notification job runs
    Then an event reminder email should be sent
    And the email should contain "Retirement Party"
    And the email should contain "Retirement"

  Scenario: Gift suggestion is included in gift reminder
    Given an event "Christmas" exists starting "1 week" from now
    And the event has "1" recipients
    And I am an attendee of the event
    And I have gift reminders enabled with "Week Before" timing
    When the notification job runs
    Then a gift reminder email should be sent
    And the email should contain gift suggestions for the recipient
