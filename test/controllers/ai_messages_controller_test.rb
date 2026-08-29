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

  test "generates title for a new conversation" do
    conversation = @user.ai_conversations.create!(
      title: "New Conversation"
    )
  
    fake_assistant = Minitest::Mock.new
  
    fake_assistant.expect(
      :ask,
      "You are working on a website project.",
      ["What project am I working on?"]
    )
  
    fake_assistant.expect(
      :generate_title,
      "Current Website Project",
      ["What project am I working on?"]
    )
  
    Ai::ClientAssistant.stub :new, fake_assistant do
      post ai_conversation_ai_messages_url(conversation),
           params: {
             content: "What project am I working on?"
           }
    end
  
    assert_redirected_to ai_conversation_url(conversation)
  
    conversation.reload
  
    assert_equal "Current Website Project", conversation.title
  
    fake_assistant.verify
  end

  test "does not regenerate title for an existing conversation" do
    conversation = @user.ai_conversations.create!(
      title: "Current Website Project"
    )
  
    fake_assistant = Minitest::Mock.new
  
    fake_assistant.expect(
      :ask,
      "The deadline is not specified.",
      ["What is its deadline?"]
    )
  
    Ai::ClientAssistant.stub :new, fake_assistant do
      post ai_conversation_ai_messages_url(conversation),
           params: {
             content: "What is its deadline?"
           }
    end
  
    assert_redirected_to ai_conversation_url(conversation)
  
    conversation.reload
  
    assert_equal "Current Website Project", conversation.title
  
    fake_assistant.verify
  end

  test "streams assistant response and saves messages" do
    conversation = @user.ai_conversations.create!(
      title: "Streaming Test"
    )
  
    fake_assistant = Object.new
  
    fake_assistant.define_singleton_method(:stream_answer) do |question, &block|
      raise "Unexpected question" unless question == "What should I focus on today?"
  
      block.call("Focus")
      block.call(" on")
      block.call(" your highest-priority tasks.")
    end
  
    Ai::ClientAssistant.stub :new, fake_assistant do
      post stream_ai_conversation_ai_messages_url(conversation),
           params: {
             content: "What should I focus on today?"
           }
    end
  
    assert_response :success
  
    assert_equal 2, conversation.ai_messages.count
  
    user_message = conversation.ai_messages.order(:created_at).first
    assistant_message = conversation.ai_messages.order(:created_at).last
  
    assert_equal "user", user_message.role
  
    assert_equal(
      "What should I focus on today?",
      user_message.content
    )
  
    assert_equal "assistant", assistant_message.role
  
    assert_equal(
      "Focus on your highest-priority tasks.",
      assistant_message.content
    )
  end

  test "streams an error event when OpenAI fails" do
    conversation = @user.ai_conversations.create!(
      title: "Streaming Error Test"
    )
  
    fake_assistant = Object.new
  
    fake_assistant.define_singleton_method(:stream_answer) do |_question, &_block|
      raise OpenAI::Errors::APIError.new(
        url: "https://api.openai.com/v1/responses",
        message: "Test streaming failure"
      )
    end
  
    Ai::ClientAssistant.stub :new, fake_assistant do
      post stream_ai_conversation_ai_messages_url(conversation),
           params: {
             content: "What should I focus on today?"
           }
    end
  
    assert_response :success
  
    assert_includes response.body, "event: error"
    assert_includes(
      response.body,
      "The AI assistant is temporarily unavailable."
    )
  end
end