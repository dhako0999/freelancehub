require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
    test "user only sees their own clients" do
      user = users(:one)
  
      visit new_session_url
  
      fill_in "Email address", with: user.email_address
      fill_in "Password", with: "password"
  
      click_button "Sign in"
  
      click_link "Clients"
  
      assert_text "First User Client"
      assert_no_text "Second User Client"
    end

    test "user can create a client" do
        user = users(:one)
      
        visit new_session_url
      
        fill_in "Email address", with: user.email_address
        fill_in "Password", with: "password"
      
        click_button "Sign in"
      
        click_link "Clients"
        click_link "Add Client"
      
        fill_in "Name", with: "System Test Client"
        fill_in "Email", with: "system-client@example.com"
        fill_in "Company", with: "System Test Company"
        fill_in "Phone", with: "555-444-4444"
        fill_in "Notes", with: "Created by a Rails system test."
      
        click_button "Create Client"
      
        assert_text "Client was successfully created."
      
        click_link "Next"
      
        assert_text "System Test Client"
    end

    test "user can upload and remove a client file" do
      user = users(:one)
      client = clients(:one)
  
      visit new_session_path
  
      fill_in "Email address", with: user.email_address
      fill_in "Password", with: "password"
  
      click_button "Sign in"
  
      assert_text "Dashboard"
  
      visit edit_client_path(client)
  
      attach_file(
        "Client Files",
        Rails.root.join("test/fixtures/files/sample.txt")
      )
  
      click_button "Update Client"
  
      assert_text "Client was successfully updated."
      assert_text "sample.txt"
  
      accept_confirm "Are you sure you want to remove this file?" do
        click_button "Remove"
      end
  
      assert_text "File was successfully removed."
      assert_no_text "sample.txt"
    end
end