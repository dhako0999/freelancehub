require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")

    assert_equal "downcased@example.com", user.email_address
  end

  test "email is not verified when email_verified_at is nil" do
    user = users(:one)
    user.update!(email_verified_at: nil)

    assert_not user.email_verified?
  end

  test "email is verified when email_verified_at is present" do
    user = users(:one)
    user.update!(email_verified_at: Time.current)

    assert user.email_verified?
  end

  test "email verification token resolves to the correct user" do
    user = users(:one)

    token = user.generate_token_for(:email_verification)

    assert_equal user, User.find_by_token_for(:email_verification, token)
  end

  test "email verification token becomes invalid after email address changes" do
    user = users(:one)

    token = user.generate_token_for(:email_verification)

    user.update!(email_address: "changed@example.com")

    assert_nil User.find_by_token_for(:email_verification, token)
  end
end
