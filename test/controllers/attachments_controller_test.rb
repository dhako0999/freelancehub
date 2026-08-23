require "test_helper"

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    @user = users(:one)
    @other_user = users(:two)

    sign_in_as(@user)

    @client = clients(:one)
    @other_client = clients(:two)

    @project = @client.projects.create!(
      name: "Attachment Project",
      status: "Active"
    )

    @other_project = @other_client.projects.create!(
      name: "Other Attachment Project",
      status: "Active"
    )
  end

  test "user can remove attachment from own project" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.txt"),
      "text/plain"
    )

    @project.files.attach(file)

    attachment = @project.files.first

    assert_difference("ActiveStorage::Attachment.count", -1) do
      delete attachment_url(attachment)
    end

    assert_redirected_to client_project_url(@client, @project)
  end

  test "user cannot remove attachment from another user's project" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.txt"),
      "text/plain"
    )

    @other_project.files.attach(file)

    attachment = @other_project.files.first

    assert_no_difference("ActiveStorage::Attachment.count") do
      delete attachment_url(attachment)
    end

    assert_response :not_found
  end
end
