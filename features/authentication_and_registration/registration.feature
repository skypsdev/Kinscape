Feature: Registration
  Scenario: Registering with valid details
    When I sign up using valid details
    Then I am presented with the onboarding dialog
    When I fulfill onboarding dialog
    Then I am presented with the my life page

  Scenario: Registering with invalid details
    When I sign up using invalid details
    Then I am presented with the sign up page
    And I am informed of an error

  Scenario: Registering with an already taken email address
    When I sign up using an email address already linked to an account
    Then I am presented with the sign up page
    And I am informed that the email address is already taken
