Feature: Offline Member
  Background:
    Given I am authenticated
    And I am presented with the onboarding dialog
    And I fulfill onboarding dialog
    And I have created a community

  Scenario: Create/Edit offline member
    When I create a new offline member
    Then it should appear in my communities list
    When I edit the details of the offline member
    Then those updates should be seen on the member page

