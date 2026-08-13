require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)

    @client = clients(:one)
    @other_client = clients(:two)

    sign_in_as(@user)

    @project = @client.projects.create!(
      name: "First User Project",
      status: "Active"
    )

    @other_project = @other_client.projects.create!(
      name: "Second User Project",
      status: "Active"
    )

    @task = @project.tasks.create!(
      title: "First User Task",
      status: "Active",
      priority: "Medium"
    )

    @other_task = @other_project.tasks.create!(
      title: "Second User Task",
      status: "Active",
      priority: "Medium"
    )
  end

  test "should get index" do
    get client_project_tasks_url(@client, @project)

    assert_response :success
  end

  test "index should show current user's task" do
    get client_project_tasks_url(@client, @project)

    assert_response :success
    assert_select "body", text: /First User Task/
  end

  test "should get new" do
    get new_client_project_task_url(@client, @project)

    assert_response :success
  end

  test "should show own task" do
    get client_project_task_url(@client, @project, @task)

    assert_response :success
    assert_select "body", text: /First User Task/
  end

  test "should get edit for own task" do
    get edit_client_project_task_url(@client, @project, @task)

    assert_response :success
  end

  test "should create task under own project" do
    assert_difference("@project.tasks.count", 1) do
      post client_project_tasks_url(@client, @project), params: {
        task: {
          title: "New Task",
          status: "Active",
          priority: "High"
        }
      }
    end

    created_task = @project.tasks.order(:created_at).last

    assert_equal @project, created_task.project

    assert_redirected_to client_project_task_url(
      @client,
      @project,
      created_task
    )
  end

  test "should update own task" do
    patch client_project_task_url(@client, @project, @task), params: {
      task: {
        title: "Updated Task",
        status: "Completed",
        priority: "High"
      }
    }

    assert_redirected_to client_project_task_url(
      @client,
      @project,
      @task
    )

    @task.reload

    assert_equal "Updated Task", @task.title
    assert_equal "Completed", @task.status
    assert_equal "High", @task.priority
  end

  test "should destroy own task" do
    assert_difference("@project.tasks.count", -1) do
      delete client_project_task_url(@client, @project, @task)
    end

    assert_redirected_to client_project_url(@client, @project)
  end

  test "should not access another user's task index" do
    get client_project_tasks_url(@other_client, @other_project)

    assert_response :not_found
  end

  test "should not show another user's task" do
    get client_project_task_url(
      @other_client,
      @other_project,
      @other_task
    )

    assert_response :not_found
  end

  test "should not edit another user's task" do
    get edit_client_project_task_url(
      @other_client,
      @other_project,
      @other_task
    )

    assert_response :not_found
  end

  test "should not update another user's task" do
    original_title = @other_task.title

    patch client_project_task_url(
      @other_client,
      @other_project,
      @other_task
    ), params: {
      task: {
        title: "Unauthorized Update",
        status: "Completed",
        priority: "High"
      }
    }

    assert_response :not_found
    assert_equal original_title, @other_task.reload.title
  end

  test "should not destroy another user's task" do
    assert_no_difference("Task.count") do
      delete client_project_task_url(
        @other_client,
        @other_project,
        @other_task
      )
    end

    assert_response :not_found
    assert Task.exists?(@other_task.id)
  end

  test "signed-out user should be redirected from task index" do
    sign_out

    get client_project_tasks_url(@client, @project)

    assert_redirected_to new_session_url
  end

  test "signed-out user should be redirected from task page" do
    sign_out

    get client_project_task_url(@client, @project, @task)

    assert_redirected_to new_session_url
  end
end
