require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)

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
  end

  test "should get index" do
    get client_projects_url(@client)

    assert_response :success
  end

  test "index should show current user's project" do
    get client_projects_url(@client)

    assert_response :success
    assert_select "body", text: /First User Project/
  end

  test "should get new" do
    get new_client_project_url(@client)

    assert_response :success
  end

  test "should show own project" do
    get client_project_url(@client, @project)

    assert_response :success
    assert_select "body", text: /First User Project/
  end

  test "should get edit for own project" do
    get edit_client_project_url(@client, @project)

    assert_response :success
  end

  test "should create project under own client" do
    assert_difference("@client.projects.count", 1) do
      post client_projects_url(@client), params: {
        project: {
          name: "New Project",
          status: "Active"
        }
      }
    end

    created_project = @client.projects.order(:created_at).last

    assert_equal @client, created_project.client
    assert_redirected_to client_project_url(@client, created_project)
  end

  test "should update own project" do
    patch client_project_url(@client, @project), params: {
      project: {
        name: "Updated Project",
        status: "Completed"
      }
    }

    assert_redirected_to client_project_url(@client, @project)

    @project.reload

    assert_equal "Updated Project", @project.name
    assert_equal "Completed", @project.status
  end

  test "should destroy own project" do
    assert_difference("@client.projects.count", -1) do
      delete client_project_url(@client, @project)
    end

    assert_redirected_to client_url(@client)
  end

  test "should not access another user's project index" do
    get client_projects_url(@other_client)

    assert_response :not_found
  end

  test "should not show another user's project" do
    get client_project_url(@other_client, @other_project)

    assert_response :not_found
  end

  test "should not edit another user's project" do
    get edit_client_project_url(@other_client, @other_project)

    assert_response :not_found
  end

  test "should not update another user's project" do
    original_name = @other_project.name

    patch client_project_url(@other_client, @other_project), params: {
      project: {
        name: "Unauthorized Update",
        status: "Completed"
      }
    }

    assert_response :not_found
    assert_equal original_name, @other_project.reload.name
  end

  test "should not destroy another user's project" do
    assert_no_difference("Project.count") do
      delete client_project_url(@other_client, @other_project)
    end

    assert_response :not_found
    assert Project.exists?(@other_project.id)
  end

  test "signed-out user should be redirected from project index" do
    sign_out

    get client_projects_url(@client)

    assert_redirected_to new_session_url
  end

  test "signed-out user should be redirected from project page" do
    sign_out

    get client_project_url(@client, @project)

    assert_redirected_to new_session_url
  end


  test "should attach valid file to own project" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.txt"),
      "text/plain"
    )
  
    assert_difference("@project.reload.files.count", 1) do
      patch client_project_url(@client, @project), params: {
        project: {
          name: @project.name,
          status: @project.status,
          files: [file]
        }
      }
    end
  
    assert_redirected_to client_project_url(@client, @project)
  end

  test "should reject unsuppported file type" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.exe"),
      "application/octet-stream"
    )

    original_count = @project.files.count

    patch client_project_url(@client, @project), params: {
      project: {
        name: @project.name,
        status: @project.status,
        files: [file]
      }
    }

    assert_response :unprocessable_entity
    assert_equal original_count, @project.reload.files.count
  end

  test "should reject file larger than 10 MB" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/large.txt"),
      "text/plain"
    )
  
    patch client_project_url(@client, @project), params: {
      project: {
        name: @project.name,
        status: @project.status,
        files: [file]
      }
    }
  
    assert_response :unprocessable_entity
    assert_equal 0, @project.reload.files.count
  end
end
