require "test_helper"

class AiConversationTest < ActiveSupport::TestCase
  test "requires a title" do
    conversation = AiConversation.new(
      user: users(:one),
      title: ""
    )

    assert_not conversation.valid?
    assert_includes conversation.errors[:title], "can't be blank"
  end

  test "title cannot exceed 100 characters" do
    conversation = AiConversation.new(
      user: users(:one),
      title: "a" * 101
    )

    assert_not conversation.valid?
    assert_includes conversation.errors[:title],
                    "is too long (maximum is 100 characters)"
  end

  test "valid conversation is valid" do
    conversation = AiConversation.new(
      user: users(:one),
      title: "Project Planning"
    )

    assert conversation.valid?
  end
end
