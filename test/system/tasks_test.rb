require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
    test "user can create a task" do
      user = users(:one)
      client = clients(:one)
  
      project = client.projects.create!(
        name: "System Test Project",
        status: "Active"
      )
  
      visit new_session_path
  
      fill_in "Email address", with: user.email_address
      fill_in "Password", with: "password"
  
      click_button "Sign in"
  
      assert_text "Dashboard"
  
      visit new_client_project_task_path(client, project)
  
      assert_current_path new_client_project_task_path(client, project)
  
      fill_in "Title", with: "System Test Task"
      fill_in "Status", with: "Active"
      select "High", from: "Priority"
  
      click_button "Create Task"
  
      assert_text "Task was successfully created."
      assert_text "System Test Task"
    end
end