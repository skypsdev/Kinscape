Feature: My Live
  @wip @javascript
  Scenario: Updating my personal details
    Given I am authenticated
    And I navigate to the my life page
    When I update my personal details
    Then my personal details should be visible to others

  @wip
  Scenario: Adding my first chapter to my profile
    Given I am authenticated
    And I navigate to the my life page
    When I add my first chapter to my profile
    Then my first chapter should be visible to others

  @wip
  Scenario: Adding an addition chapter to my profile
    Given I am authenticated
    And I navigate to the my life page
    And I already have a chapter
    When I add a new additional chapter to my profile
    Then my additional chapter should be visible to others