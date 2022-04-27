Feature: Create Community
  @javascript
  Scenario: Creating a new community
    Given I am authenticated
    And I am presented with the onboarding dialog
    And I fulfill onboarding dialog
    When I create a new community
    And I add my first chapter to the community
    Then it should appear in my communities list
    And I should be able to view my new community
