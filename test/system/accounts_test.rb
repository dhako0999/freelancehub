require "application_system_test_case"


class AccountsTest < ApplicationSystemTestCase
    test "user can update profile information" do
      user = users(:one)
  
      visit new_session_path
  
      fill_in "Email address", with: user.email_address
      fill_in "Password", with: "password"
  
      click_button "Sign in"
  
      assert_text "Dashboard"
  
      find("[aria-label='Open account menu']").click
      click_link "Account Settings"
  
      find("#edit-account-link").click
  
      fill_in "First Name", with: "John"
      fill_in "Last Name", with: "Doe"
      fill_in "Company Name", with: "Doe Consulting"
  
      click_button "Save changes"
  
      assert_current_path account_path
      assert_text "Your account was successfully updated."
      assert_text "John"
      assert_text "Doe"
      assert_text "Doe Consulting"
    end
  end