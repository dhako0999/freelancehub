require "test_helper"

class EmailVerificationMailerTest < ActionMailer::TestCase
  test "verification email" do
    user = users(:one)

    mail = EmailVerificationMailer
      .with(user: user)
      .verification_email

    assert_equal "Verify your AI Client Portal email", mail.subject
    assert_equal [user.email_address], mail.to

    assert_match "Verify your email address", mail.body.encoded
    assert_match "email_verification", mail.body.encoded
  end
end
