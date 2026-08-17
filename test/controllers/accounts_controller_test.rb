require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get show" do
    get account_url

    assert_response :success
  end

  test "should get edit" do
    get edit_account_url

    assert_response :success
  end

  test "should update email address and require reverification" do
    patch account_url, params: {
      user: {
        email_address: "updated@example.com"
      }
    }
  
    @user.reload
  
    assert_equal "updated@example.com", @user.email_address
    assert_nil @user.email_verified_at
    assert_redirected_to new_session_url
  end

  test "should not update account with blank email address" do
    original_email = @user.email_address

    patch account_url, params: {
      user: {
        email_address: ""
      }
    }

    assert_response :unprocessable_entity
    assert_equal original_email, @user.reload.email_address
  end

  test "should redirect signed-out user from account page" do
    sign_out
  
    get account_url
  
    assert_redirected_to new_session_url
  end
  
  test "should redirect signed-out user from edit account page" do
    sign_out
  
    get edit_account_url
  
    assert_redirected_to new_session_url
  end
  
  test "should not allow signed-out user to update account" do
    original_email = @user.email_address
  
    sign_out
  
    patch account_url, params: {
      user: {
        email_address: "unauthorized@example.com"
      }
    }
  
    assert_redirected_to new_session_url
    assert_equal original_email, @user.reload.email_address
  end

  test "changing email requires reverification" do
    patch account_url, params: {
      user: {
        email_address: "new-address@example.com"
      }
    }
  
    @user.reload
  
    assert_equal "new-address@example.com", @user.email_address
    assert_nil @user.email_verified_at
    assert_redirected_to new_session_url
  end
  
  test "changing email sends verification email" do
    assert_enqueued_emails 1 do
      patch account_url, params: {
        user: {
          email_address: "new-address@example.com"
        }
      }
    end
  end
end

