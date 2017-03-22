Feature:
  As a user
  I want to re-define my forgotten password
  So that I can use the OpenRedu even when I forgot my password

  @forgotten_password @sc01 @sanity @clean @tobeautomated @semi-manual
  Scenario Outline: Send request for password redefinition
  Given I am at the "Retrieve Password" page
  When  I fill the email field with "<email>"
  Then  I should have received a password redefinition request via the "<email>" email
  Examples:
  | email                 |
  | redu@redu.com.br      |
  | test_user@example.com |
