require "test_helper"

class TaskReminderMailerTest < ActionMailer::TestCase
  test "task_due_reminder" do
    mail = TaskReminderMailer.task_due_reminder
    assert_equal "Task due reminder", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
