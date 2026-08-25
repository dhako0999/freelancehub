require "test_helper"
require "minitest/mock"

class AssistantControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get assistant page" do
    get assistant_url

    assert_response :success
  end

  test "should answer a valid question" do
    fake_assistant = Minitest::Mock.new

    fake_assistant.expect(
      :ask,
      "You currently have no active projects.",
      ["What projects do I currently have?"]
    )

    Ai::ClientAssistant.stub :new, fake_assistant do
      post assistant_url, params: {
        question: "What projects do I currently have?"
      }

      assert_response :success
      assert_select "body", text: /You currently have no active projects/
    end

    fake_assistant.verify
  end

  test "should reject blank question" do
    post assistant_url, params: {
      question: ""
    }

    assert_response :unprocessable_entity
    assert_select "body", text: /Enter a question/
  end
end