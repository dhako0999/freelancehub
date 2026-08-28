require "test_helper"

class AiConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "updates own conversation title" do
    conversation = @user.ai_conversations.create!(
      title: "Old Title"
    )

    patch ai_conversation_url(conversation),
          params: {
            ai_conversation: {
              title: "Updated Title"
            }
          }

    assert_redirected_to ai_conversation_url(conversation)

    conversation.reload

    assert_equal "Updated Title", conversation.title
  end

  test "destroys own conversation" do
    conversation = @user.ai_conversations.create!(
      title: "Delete Me"
    )

    assert_difference -> { AiConversation.count }, -1 do
      delete ai_conversation_url(conversation)
    end

    assert_redirected_to ai_conversations_url
  end

  test "cannot update another user's conversation" do
    other_user = users(:two)

    conversation = other_user.ai_conversations.create!(
      title: "Private Conversation"
    )

    patch ai_conversation_url(conversation),
          params: {
            ai_conversation: {
              title: "Changed Title"
            }
          }

    assert_response :not_found

    assert_equal "Private Conversation",
                 conversation.reload.title
  end

  test "cannot destroy another user's conversation" do
    other_user = users(:two)

    conversation = other_user.ai_conversations.create!(
      title: "Private Conversation"
    )

    assert_no_difference -> { AiConversation.count } do
      delete ai_conversation_url(conversation)
    end

    assert_response :not_found
  end
end