require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    Rails.cache.clear
  end

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

  test "should get resend verification form" do
    get new_email_verification_url
  
    assert_response :success
  end
  
  test "resends verification email for unverified user" do
    user = users(:one)
    user.update!(email_verified_at: nil)
  
    assert_enqueued_emails 1 do
      post resend_email_verification_url,
           params: { email_address: user.email_address }
    end
  
    assert_redirected_to new_session_url
  end
  
  test "does not resend verification email for verified user" do
    user = users(:one)
  
    assert user.email_verified?
  
    assert_enqueued_emails 0 do
      post resend_email_verification_url,
           params: { email_address: user.email_address }
    end
  
    assert_redirected_to new_session_url
  end
  
  test "does not reveal whether unknown email exists" do
    assert_enqueued_emails 0 do
      post resend_email_verification_url,
           params: { email_address: "unknown@example.com" }
    end
  
    assert_redirected_to new_session_url
  
    assert_equal(
      "If an unverified account exists for that email address, a new verification email has been sent.",
      flash[:notice]
    )
  end

  test "rate limits repeated verification email requests" do
    user = users(:one)
    user.update!(email_verified_at: nil)
  
    post resend_email_verification_url,
         params: { email_address: user.email_address }
  
    assert_redirected_to new_session_url
  
    post resend_email_verification_url,
         params: { email_address: user.email_address }
  
    assert_redirected_to new_email_verification_url
  
    assert_equal(
      "Please wait a minute before requesting another verification email.",
      flash[:alert]
    )
  end
end
