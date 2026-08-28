require "application_system_test_case"

class AiConversationsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)

    visit new_session_path

    fill_in "Email address", with: @user.email_address
    fill_in "Password", with: "password"

    click_button "Sign in"

    assert_text "Dashboard"
  end

  test "renames a conversation" do
    conversation = @user.ai_conversations.create!(
      title: "Old Conversation Title"
    )

    visit ai_conversation_path(conversation)

    fill_in "ai_conversation_title",
            with: "Updated Conversation Title"

    click_on "Rename"

    assert_text "Conversation was successfully renamed."
    assert_field "ai_conversation_title",
                 with: "Updated Conversation Title"

    conversation.reload

    assert_equal "Updated Conversation Title",
                 conversation.title
  end

  test "deletes a conversation" do
    conversation = @user.ai_conversations.create!(
      title: "Conversation To Delete"
    )

    visit ai_conversation_path(conversation)

    accept_confirm do
      click_on "Delete"
    end

    assert_current_path ai_conversations_path
    assert_text "Conversation was successfully deleted."

    assert_not AiConversation.exists?(conversation.id)
  end

  test "suggested prompt fills the message field" do
    client = @user.clients.create!(
      name: "Test Client",
      email: "client@example.com",
      company: "Test Company",
      phone: "555-123-4567",
      notes: "Test client notes"
    )
  
    conversation = @user.ai_conversations.create!(
      title: "Test Conversation"
    )
  
    visit ai_conversation_path(conversation)
  
    click_on "Summarize my current clients."
  
    assert_field "content",
                 with: "Summarize my current clients."
  end
end