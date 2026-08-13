require "test_helper"

class TaskReminderMailerTest < ActionMailer::TestCase
  setup do
    @client = clients(:one)

    @project = @client.projects.create!(
      name: "Reminder Test Project",
      status: "Active"
    )

    @task = @project.tasks.create!(
      title: "Finish proposal",
      status: "Active",
      priority: "High"
    )
  end

  test "task due reminder" do
    mail = TaskReminderMailer.with(task: @task).task_due_reminder

    assert_equal "Task Reminder: Finish proposal is due soon", mail.subject
    assert_equal [@client.email], mail.to
    assert_match "Finish proposal", mail.body.encoded
  end
end
