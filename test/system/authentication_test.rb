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


  test "user can register and is automatically signed in" do
    visit new_registration_url
  
    fill_in "Email address", with: "newuser@example.com"
    fill_in "Password", with: "Password123!"
    fill_in "Confirm password", with: "Password123!"
  
    click_button "Create account"
  
    assert_text "Dashboard"
    assert_text "newuser@example.com"
  end

  test "user can update account email" do
    user = users(:one)
  
    visit new_session_url
  
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
  
    click_button "Sign in"
  
    find("[aria-label='Open account menu']").click
    click_link "Account Settings"
  
    assert_text "Account Settings"
  
    find("#edit-account-link").click
  
    fill_in "Email address", with: "updated-account@example.com"
  
    click_button "Save changes"
  
    assert_text "Your account was successfully updated."
    assert_text "updated-account@example.com"
  end

  
end