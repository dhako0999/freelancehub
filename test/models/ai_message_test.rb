require "test_helper"

class AiMessageTest < ActiveSupport::TestCase
  setup do
    @conversation = AiConversation.create!(
      user: users(:one),
      title: "Test Conversation"
    )
  end

  test "requires content" do
    message = @conversation.ai_messages.new(
      role: "user",
      content: ""
    )

    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end

  test "requires a valid role" do
    message = @conversation.ai_messages.new(
      role: "invalid",
      content: "Hello"
    )

    assert_not message.valid?
    assert_includes message.errors[:role], "is not included in the list"
  end

  test "allows user role" do
    message = @conversation.ai_messages.new(
      role: "user",
      content: "What projects do I have?"
    )

    assert message.valid?
  end

  test "allows assistant role" do
    message = @conversation.ai_messages.new(
      role: "assistant",
      content: "You currently have three projects."
    )

    assert message.valid?
  end
end
