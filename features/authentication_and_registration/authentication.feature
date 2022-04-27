Feature: Authentication
  Scenario: Successful authentication
    Given I have an active user account
    When I authenticate with valid account details
    Then I am presented with the onboarding dialog
    When I fulfill onboarding dialog
    Then I am presented with the my life page

  Scenario: Unsuccessful authentication
    Given I have an active user account
    When I authenticate with invalid account details
    Then I am presented with the sign in page
    And I am presented with an error message
