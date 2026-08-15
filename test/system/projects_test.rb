require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  test "user can create a project" do
    user = users(:one)
    client = clients(:one)

    visit new_session_path

    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"

    click_button "Sign in"

    assert_text "Dashboard"

    visit new_client_project_path(client)

    assert_current_path new_client_project_path(client)
    assert_text "Project Name"

    fill_in "Project Name", with: "System Test Project"
    select "Active", from: "Status"

    click_button "Create Project"

    assert_text "Project was successfully created."
    assert_text "System Test Project"
  end
end