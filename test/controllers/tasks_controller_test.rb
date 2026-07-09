require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = Client.create!(
      name: "Test Client",
      email: "test@example.com",
      company: "Test Company",
      phone: "123-456-7890",
      notes: "Test notes"
    )

    @project = @client.projects.create!(
      name: "Test Project",
      status: "Active"
    )

    @task = @project.tasks.create!(
      title: "Test Task",
      status: "Active",
      priority: "Medium"
    )
  end

  test "should get index" do
    get client_project_tasks_url(@client, @project)
    assert_response :success
  end

  test "should get new" do
    get new_client_project_task_url(@client, @project)
    assert_response :success
  end

  test "should get show" do
    get client_project_task_url(@client, @project, @task)
    assert_response :success
  end

  test "should get edit" do
    get edit_client_project_task_url(@client, @project, @task)
    assert_response :success
  end
end
