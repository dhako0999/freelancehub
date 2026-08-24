require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @own_client = clients(:one)
    @other_client = clients(:two)

    sign_in_as(@user)
  end

  test "should get index" do
    get clients_url

    assert_response :success
  end

  test "index should show current user's client" do
    get clients_url

    assert_response :success
    assert_select "body", text: /First User Client/
  end

  test "index should not show another user's client" do
    get clients_url

    assert_response :success
    assert_select "body", text: /Second User Client/, count: 0
  end

  test "should get new" do
    get new_client_url

    assert_response :success
  end

  test "should show own client" do
    get client_url(@own_client)

    assert_response :success
    assert_select "body", text: /First User Client/
  end

  test "should not show another user's client" do
    get client_url(@other_client)

    assert_response :not_found
  end

  test "should create client for current user" do
    assert_difference("@user.clients.count", 1) do
      post clients_url, params: {
        client: {
          name: "New Client",
          email: "new-client@example.com",
          company: "New Company",
          phone: "555-333-3333",
          notes: "Created in controller test"
        }
      }
    end

    created_client = Client.order(:created_at).last

    assert_equal @user, created_client.user
    assert_redirected_to clients_url
  end

  test "should update own client" do
    patch client_url(@own_client), params: {
      client: {
        name: "Updated Client Name",
        email: @own_client.email,
        company: @own_client.company,
        phone: @own_client.phone,
        notes: @own_client.notes
      }
    }

    assert_redirected_to client_url(@own_client)
    assert_equal "Updated Client Name", @own_client.reload.name
  end

  test "should not update another user's client" do
    original_name = @other_client.name

    patch client_url(@other_client), params: {
      client: {
        name: "Unauthorized Update",
        email: @other_client.email,
        company: @other_client.company,
        phone: @other_client.phone,
        notes: @other_client.notes
      }
    }

    assert_response :not_found
    assert_equal original_name, @other_client.reload.name
  end

  test "should destroy own client" do
    assert_difference("@user.clients.count", -1) do
      delete client_url(@own_client)
    end

    assert_redirected_to clients_url
  end

  test "should not destroy another user's client" do
    assert_no_difference("Client.count") do
      delete client_url(@other_client)
    end

    assert_response :not_found
    assert Client.exists?(@other_client.id)
  end

  test "signed-out user should be redirected from index" do
    sign_out

    get clients_url

    assert_redirected_to new_session_url
  end

  test "signed-out user should be redirected from client page" do
    sign_out

    get client_url(@own_client)

    assert_redirected_to new_session_url
  end

  test "should attach valid file to own client" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.txt"),
      "text/plain"
    )
  
    assert_difference -> { @own_client.reload.files.count }, 1 do
      patch client_url(@own_client), params: {
        client: {
          name: @own_client.name,
          email: @own_client.email,
          company: @own_client.company,
          phone: @own_client.phone,
          notes: @own_client.notes,
          files: [file]
        }
      }
    end
  
    assert_redirected_to client_url(@own_client)
  end

  test "should reject unsupported client file type" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.exe"),
      "application/octet-stream"
    )
  
    original_count = @own_client.files.count
  
    patch client_url(@own_client), params: {
      client: {
        name: @own_client.name,
        email: @own_client.email,
        company: @own_client.company,
        phone: @own_client.phone,
        notes: @own_client.notes,
        files: [file]
      }
    }
  
    assert_response :unprocessable_entity
    assert_equal original_count, @own_client.reload.files.count
  end

  test "should reject client file larger than 10 MB" do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/large.txt"),
      "text/plain"
    )
  
    original_count = @own_client.files.count
  
    patch client_url(@own_client), params: {
      client: {
        name: @own_client.name,
        email: @own_client.email,
        company: @own_client.company,
        phone: @own_client.phone,
        notes: @own_client.notes,
        files: [file]
      }
    }
  
    assert_response :unprocessable_entity
    assert_equal original_count, @own_client.reload.files.count
  end
end
