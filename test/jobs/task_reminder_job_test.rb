require "test_helper"

class TaskReminderJobTest < ActiveJob::TestCase

  setup do
    ActionMailer::Base.deliveries.clear
    Task.delete_all
  
    @user = users(:one)
    @other_user = users(:two)
  
    @client = clients(:one)
    @other_client = clients(:two)
  
    @project = @client.projects.create!(
      name: "Reminder Project",
      status: "Active"
    )
  
    @other_project = @other_client.projects.create!(
      name: "Other Reminder Project",
      status: "Active"
    )
  end

  test "sends reminder for task matching user's reminder preference" do
    @user.update!(
      task_reminders_enabled: true,
      reminder_days_before: 2
    )

    @project.tasks.create!(
      title: "Due Soon Task",
      status: "Active",
      priority: "High",
      due_date: Date.current + 2.days
    )

    assert_difference("ActionMailer::Base.deliveries.size", 1) do
      TaskReminderJob.perform_now
    end
  end

  test "does not send reminder when reminders are disabled" do
    @user.update!(
      task_reminders_enabled: false,
      reminder_days_before: 2
    )

    @project.tasks.create!(
      title: "Disabled Reminder Task",
      status: "Active",
      priority: "High",
      due_date: Date.current + 2.days
    )

    assert_no_difference("ActionMailer::Base.deliveries.size") do
      TaskReminderJob.perform_now
    end
  end

  test "does not send reminder for task outside reminder preference" do
    @user.update!(
      task_reminders_enabled: true,
      reminder_days_before: 2
    )

    @project.tasks.create!(
      title: "Wrong Reminder Date",
      status: "Active",
      priority: "High",
      due_date: Date.current + 7.days
    )

    assert_no_difference("ActionMailer::Base.deliveries.size") do
      TaskReminderJob.perform_now
    end
  end

  test "does not send reminder for completed task" do
    @user.update!(
      task_reminders_enabled: true,
      reminder_days_before: 2
    )

    @project.tasks.create!(
      title: "Completed Task",
      status: "Completed",
      priority: "High",
      due_date: Date.current + 2.days
    )

    assert_no_difference("ActionMailer::Base.deliveries.size") do
      TaskReminderJob.perform_now
    end
  end

  test "sends reminders only for current user's tasks" do
    @user.update!(
      task_reminders_enabled: true,
      reminder_days_before: 2
    )

    @other_user.update!(
      task_reminders_enabled: false,
      reminder_days_before: 2
    )

    @project.tasks.create!(
      title: "First User Task",
      status: "Active",
      priority: "High",
      due_date: Date.current + 2.days
    )

    @other_project.tasks.create!(
      title: "Second User Task",
      status: "Active",
      priority: "High",
      due_date: Date.current + 2.days
    )

    assert_difference("ActionMailer::Base.deliveries.size", 1) do
      TaskReminderJob.perform_now
    end
  end

  test "can send overdue reminder again on a later day" do
    @user.update!(
      task_reminders_enabled: true,
      reminder_days_before: 2
    )
  
    task = @project.tasks.create!(
      title: "Repeat Overdue Reminder Task",
      status: "Active",
      priority: "High",
      due_date: Date.current - 2.days,
      overdue_reminder_sent_at: 1.day.ago
    )
  
    assert_difference("ActionMailer::Base.deliveries.size", 1) do
      TaskReminderJob.perform_now
    end
  
    assert_not_nil task.reload.overdue_reminder_sent_at
  end

  test "due soon reminder does not block overdue reminder later" do
    @user.update!(
      task_reminders_enabled: true,
      reminder_days_before: 2
    )
  
    task = @project.tasks.create!(
      title: "Transition Task",
      status: "Active",
      priority: "High",
      due_date: Date.current + 2.days
    )
  
    TaskReminderJob.perform_now
  
    assert_not_nil task.reload.due_soon_reminder_sent_at
    assert_nil task.overdue_reminder_sent_at
  
    travel 3.days do
      assert_difference("ActionMailer::Base.deliveries.size", 1) do
        TaskReminderJob.perform_now
      end
  
      assert_not_nil task.reload.overdue_reminder_sent_at
    end
  end

  test "does not send duplicate due soon reminder" do
    @user.update!(
      task_reminders_enabled: true,
      reminder_days_before: 2
    )
  
    task = @project.tasks.create!(
      title: "Single Due Soon Reminder",
      status: "Active",
      priority: "High",
      due_date: Date.current + 2.days
    )
  
    TaskReminderJob.perform_now
  
    assert_not_nil task.reload.due_soon_reminder_sent_at
    assert_nil task.overdue_reminder_sent_at
  
    assert_no_difference("ActionMailer::Base.deliveries.size") do
      TaskReminderJob.perform_now
    end
  end
end
