Feature:
  As a user
  I want to create an account on OpenRedu
  So that I can log into the OpenRedu using my credentials

  @create_account @sc01 @tobeautomated
  Scenario: Create account and click outside the confirmation modal
  

  @create_account @sc02 @tobeautomated
  Scenario: Create account and click on the Try OpenRedu button

  @create_account @sc03 @tobeautomated
  Scenario: Create account using MaxLength in attributes

  @create_account @sc04 @tobeautomated
  Scenario: Fail to create account due forbidden characters in Name and Last Name

  @create_account @sc04 @tobeautomated
  Scenario: Fail to create account due unmatched emails

  @create_account @sc04 @tobeautomated
  Scenario: Fail to create account due bad formatted emails

  @create_account @sc04 @tobeautomated
  Scenario: Fail to create account due wrong Humanizer awnser

  @create_account @sc04 @tobeautomated
  Scenario: Cancel creation process by clicking on the cancel button after filling all fields

  @create_account @sc04 @tobeautomated
  Scenario: Cancel creation process by clicking outside the modal after filling all fields

  @create_account @sc04 @tobeautomated @manual
  Scenario: Check Humanizer tooltip

  @create_account @sc04 @manual
  Scenario: Check layout
