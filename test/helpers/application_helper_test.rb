require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "renders markdown bold text" do
    result = markdown("The client is **Nick Papandrea**.")

    assert_includes result, "<strong>Nick Papandrea</strong>"
  end

  test "renders markdown lists" do
    result = markdown(<<~MARKDOWN)
      Projects:

      - Website Project
      - Mobile Application
    MARKDOWN

    assert_includes result, "<ul>"
    assert_includes result, "<li>Website Project</li>"
    assert_includes result, "<li>Mobile Application</li>"
  end

  test "removes unsafe HTML" do
    result = markdown(
      'Hello <script>alert("danger")</script> world'
    )

    assert_not_includes result, "<script>"
  end

  test "returns up to four suggested prompts" do
    user = users(:one)
  
    prompts = ai_suggested_prompts(user)
  
    assert prompts.length <= 4
  
    assert_includes prompts,
                    "Summarize my current clients."
  end
end