Feature: Integration with Inovaula

  Redu should consume the Inovaula API to augment its functionalities.

  Scenario: Link accounts
    Given I am a "Teacher" with an account on Inovaula
    When I am logged in Redu as a "Teacher"
    Then I should be able to see a field where I can type my Inovaula account

  Scenario: Unlink account
    Given I am a "Teacher" with a linked account on Inovaula
    When I am logged in Redu as a "Teacher"
    And I have no "Class" "in progress"
    Then I should be able to see a link to unlink my account

  Scenario: List available contents on Inovaula
    Given I am a "Student"
    When I am in a class about "Physics"
    Then I should be able to answer exams on the subject from Inovaula
    But I should not be able to get the answers

  Scenario: Find a teacher for a class
    Given I am interested in an unavailable "Class"
    And that exists a "Teacher" with material on the subject on Inovaula
    When I open the dashboard
    Then I should be able to fire a class planning notification to a "Teacher"
