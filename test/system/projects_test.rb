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

  test "user can upload and remove a project file" do
    user = users(:one)
    client = clients(:one)
  
    project = client.projects.create!(
      name: "File Upload Project",
      status: "Active"
    )
  
    visit new_session_path
  
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
  
    click_button "Sign in"
  
    assert_text "Dashboard"
  
    visit edit_client_project_path(client, project)
  
    attach_file(
      "Files",
      Rails.root.join("test/fixtures/files/sample.txt")
    )
  
    click_button "Update Project"
  
    assert_text "Project was successfully updated."
    assert_text "sample.txt"

    accept_confirm "Are you sure you want to remove this file?" do
      click_button "Remove"
    end

    assert_text "File was successfully removed."
    assert_no_text "sample.txt"
  end
end