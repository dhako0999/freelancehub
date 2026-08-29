require "test_helper"
require "minitest/mock"

class Ai::ClientAssistantTest < ActiveSupport::TestCase
  test "includes prior conversation messages in OpenAI input" do
    user = users(:one)

    conversation = AiConversation.create!(
      user: user,
      title: "Test Conversation"
    )
  
    conversation.ai_messages.create!(
      role: "user",
      content: "What project am I working on for Nick?"
    )
  
    conversation.ai_messages.create!(
      role: "assistant",
      content: "You are working on a website project for Nick."
    )
  
    messages = conversation.ai_messages.order(:created_at).to_a
  
    fake_response = Object.new
  
    fake_response.define_singleton_method(:output_text) do
      "The deadline is not specified."
    end
  
    fake_responses = Minitest::Mock.new
  
    fake_responses.expect(
      :create,
      fake_response
    ) do |**arguments|
      input = arguments[:input]
  
      assert_equal "system", input[0][:role]
  
      assert_equal "user", input[1][:role]
      assert_equal(
        "What project am I working on for Nick?",
        input[1][:content]
      )
  
      assert_equal "assistant", input[2][:role]
      assert_equal(
        "You are working on a website project for Nick.",
        input[2][:content]
      )
  
      assert_equal "user", input[3][:role]
      assert_equal(
        "What is its deadline?",
        input[3][:content]
      )
  
      true
    end
  
    fake_client = Minitest::Mock.new
    fake_client.expect(:responses, fake_responses)
  
    OpenAI::Client.stub :new, fake_client do
      assistant = Ai::ClientAssistant.new(
        user: user,
        messages: messages
      )
  
      answer = assistant.ask("What is its deadline?")
  
      assert_equal(
        "The deadline is not specified.",
        answer
      )
    end
  
    fake_responses.verify
    fake_client.verify
  end

  test "generates a conversation title" do
    user = users(:one)
  
    fake_response = Object.new
    fake_response.define_singleton_method(:output_text) do
      "Nick's Current Project"
    end
  
    fake_responses = Minitest::Mock.new
  
    fake_responses.expect(
      :create,
      fake_response
    ) do |arguments|
      input = arguments[:input]
  
      assert_equal "system", input[0][:role]
      assert_equal "user", input[1][:role]
  
      assert_equal(
        "What project am I working on for Nick?",
        input[1][:content]
      )
  
      true
    end
  
    fake_client = Minitest::Mock.new
    fake_client.expect(:responses, fake_responses)
  
    OpenAI::Client.stub :new, fake_client do
      assistant = Ai::ClientAssistant.new(user: user)
  
      title = assistant.generate_title(
        "What project am I working on for Nick?"
      )
  
      assert_equal "Nick's Current Project", title
    end
  
    fake_responses.verify
    fake_client.verify
  end

  test "streams response text deltas" do
    user = users(:one)
  
    assistant = Ai::ClientAssistant.new(user: user)
  
    delta_one = OpenAI::Streaming::ResponseTextDeltaEvent.new(
      {
        delta: "Hello"
      }
    )
  
    delta_two = OpenAI::Streaming::ResponseTextDeltaEvent.new(
      {
        delta: " there"
      }
    )
  
    fake_stream = [delta_one, delta_two]
  
    fake_responses = Minitest::Mock.new
  
    fake_responses.expect(
      :stream,
      fake_stream
    ) do |**arguments|
      assert_equal "gpt-5.2", arguments[:model]
      assert_kind_of Array, arguments[:input]
  
      true
    end
  
    fake_client = Minitest::Mock.new
    fake_client.expect(:responses, fake_responses)
  
    assistant.instance_variable_set(
      :@client,
      fake_client
    )
  
    chunks = []
  
    assistant.stream_answer("Say hello") do |chunk|
      chunks << chunk
    end
  
    assert_equal ["Hello", " there"], chunks
  
    fake_responses.verify
    fake_client.verify
  end
end