Feature: Edit Community
  Background:
    Given I am authenticated
    And I am presented with the onboarding dialog
    And I fulfill onboarding dialog
    And I have created a community

  Scenario: Editing an existing community
    When I edit the details of the community
    Then those updates should be seen on the community page

  @wip
  Scenario: Editing a chapter on an existing community page
    When I edit a chapter within that community
    Then the updated chapter should be seen on the community page
