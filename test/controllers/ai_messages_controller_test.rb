require "test_helper"
require "minitest/mock"

class AiMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)

    @conversation = @user.ai_conversations.create!(
      title: "Test Conversation"
    )
  end

  test "creates user and assistant messages" do
    fake_assistant = Minitest::Mock.new

    fake_assistant.expect(
      :ask,
      "You are working on a website project.",
      ["What project am I working on?"]
    )

    assert_difference("@conversation.ai_messages.count", 2) do
      Ai::ClientAssistant.stub :new, fake_assistant do
        post ai_conversation_ai_messages_url(@conversation),
             params: {
               content: "What project am I working on?"
             }
      end
    end

    assert_redirected_to ai_conversation_url(@conversation)

    messages = @conversation.ai_messages.order(:created_at)

    assert_equal "user", messages.first.role
    assert_equal "What project am I working on?",
                 messages.first.content

    assert_equal "assistant", messages.last.role
    assert_equal "You are working on a website project.",
                 messages.last.content

    fake_assistant.verify
  end

  test "does not create messages for blank content" do
    assert_no_difference -> { @conversation.ai_messages.count }  do
        post ai_conversation_ai_messages_url(@conversation),
             params: { content: "    " }
    end

    assert_redirected_to ai_conversation_url(@conversation)
  end

  test "cannot create message in another user's conversation" do
    other_user = users(:two)
  
    other_conversation = other_user.ai_conversations.create!(
      title: "Other User Conversation"
    )
  
    assert_no_difference("AiMessage.count") do
      post ai_conversation_ai_messages_url(other_conversation),
           params: {
             content: "Can I access this?"
           }
    end
  
    assert_response :not_found
  end
end