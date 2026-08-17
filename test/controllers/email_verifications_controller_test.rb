require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  test "valid token verifies user" do
    user = users(:one)
    user.update!(email_verified_at: nil)

    token = user.generate_token_for(:email_verification)

    get email_verification_url(token)

    assert_redirected_to new_session_url
    assert_not_nil user.reload.email_verified_at
  end

  test "invalid token does not verify user" do
    user = users(:one)
    user.update!(email_verified_at: nil)

    get email_verification_url("invalid-token")

    assert_redirected_to new_session_url
    assert_nil user.reload.email_verified_at
  end
end
