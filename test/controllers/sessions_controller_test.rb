require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "new" do
    get new_session_path

    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "password"
    }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "wrong"
    }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "unverified user cannot sign in" do
    @user.update!(email_verified_at: nil)

    post session_path, params: {
      email_address: @user.email_address,
      password: "password"
    }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
    assert_equal "Please verify your email address before signing in.",
                 flash[:alert]
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
