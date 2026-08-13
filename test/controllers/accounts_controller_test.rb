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

  test "should update email address" do
    patch account_url, params: {
      user: {
        email_address: "updated@example.com"
      }
    }

    assert_redirected_to account_url
    assert_equal "updated@example.com", @user.reload.email_address
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
end

