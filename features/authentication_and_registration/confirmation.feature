Feature: Confirmation
  Scenario: Confirming a user account
    When I sign up using valid details
    And I confirm my account using my confirmation link
    Then I am presented with the onboarding dialog