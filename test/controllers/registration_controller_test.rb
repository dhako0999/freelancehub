require "test_helper"

class RegistrationControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url

    assert_response :success
  end

  test "creates unverified user and enqueues verification email" do
    assert_difference("User.count", 1) do
      assert_enqueued_emails 1 do
        post registration_url, params: {
          user: {
            email_address: "new-user@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end
    end

    user = User.find_by!(email_address: "new-user@example.com")

    assert_nil user.email_verified_at
    assert_redirected_to new_session_url
    assert_equal "Your account was created. Check your email to verify your account.",
                 flash[:notice]
  end

  test "does not create user with invalid registration data" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: "",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
