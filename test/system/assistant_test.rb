require "application_system_test_case"
require "minitest/mock"

class AssistantTest < ApplicationSystemTestCase
  test "user can ask the AI assistant a question" do
    user = users(:one)

    fake_assistant = Minitest::Mock.new

    fake_assistant.expect(
      :ask,
      "You currently have no active projects.",
      ["What projects do I currently have?"]
    )

    Ai::ClientAssistant.stub :new, fake_assistant do
      visit new_session_path

      fill_in "Email address", with: user.email_address
      fill_in "Password", with: "password"

      click_button "Sign in"

      assert_text "Dashboard"

      visit assistant_path

      assert_current_path assistant_path
      assert_text "Ask about your workspace"
      assert_field "Question"

      fill_in "Question",
              with: "What projects do I currently have?"

      click_button "Ask AI"

      assert_text "You currently have no active projects."
    end

    fake_assistant.verify
  end
end