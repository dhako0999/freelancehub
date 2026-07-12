class TaskReminderMailerPreview < ActionMailer::Preview
  def task_due_reminder
    task = Task
      .includes(project: :client)
      .where.not(due_date: nil)
      .first

    TaskReminderMailer
      .with(task: task)
      .task_due_reminder
  end
end         
