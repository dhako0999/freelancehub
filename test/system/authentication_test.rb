require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "user can sign in and sign out" do
    user = users(:one)

    visit new_session_url

    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"

    click_button "Sign in"

    assert_text "Dashboard"

    find("[aria-label='Open account menu']").click

    click_button "Sign out"

    assert_current_path new_session_path
  end


  test "user can register verify email and sign in" do
    visit new_registration_url
  
    fill_in "Email address", with: "newuser@example.com"
    fill_in "Password", with: "Password123!"
    fill_in "Confirm password", with: "Password123!"
  
    click_button "Create account"
  
    assert_current_path new_session_path
    assert_text "Your account was created. Check your email to verify your account."
  
    fill_in "Email address", with: "newuser@example.com"
    fill_in "Password", with: "Password123!"
  
    click_button "Sign in"
  
    assert_text "Please verify your email address before signing in."
  
    user = User.find_by!(email_address: "newuser@example.com")
    token = user.generate_token_for(:email_verification)
  
    visit email_verification_path(token)
  
    assert_current_path new_session_path
    assert_text "Your email address has been verified. You can now sign in."
  
    fill_in "Email address", with: "newuser@example.com"
    fill_in "Password", with: "Password123!"
  
    click_button "Sign in"
  
    assert_text "Dashboard"
    assert_text "newuser@example.com"
  end

  test "changing account email requires reverification" do
    user = users(:one)
  
    visit new_session_path
  
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
  
    click_button "Sign in"
  
    assert_text "Dashboard"
  
    find("[aria-label='Open account menu']").click
    click_link "Account Settings"
  
    find("#edit-account-link").click
  
    fill_in "Email address", with: "updated-account@example.com"
  
    click_button "Save changes"
  
    assert_current_path new_session_path
  
    assert_text "Your email address was updated. Check your new email to verify it before signing in."
  
    user.reload
  
    assert_nil user.email_verified_at
    assert_equal "updated-account@example.com", user.email_address
  
    token = user.generate_token_for(:email_verification)
  
    visit email_verification_path(token)
  
    assert_text "Your email address has been verified. You can now sign in."
  
    fill_in "Email address", with: "updated-account@example.com"
    fill_in "Password", with: "password"
  
    click_button "Sign in"
  
    assert_text "Dashboard"
  end

  test "user can request a new verification email" do
    user = users(:one)
    user.update!(email_verified_at: nil)
  
    visit new_session_path
  
    click_link "Resend Verification Email"
  
    assert_current_path new_email_verification_path
  
    fill_in "Email address", with: user.email_address
  
    click_button "Send Verification Email"
  
    assert_current_path new_session_path
  
    assert_text "If an unverified account exists for that email address, a new verification email has been sent."
  end

  
end