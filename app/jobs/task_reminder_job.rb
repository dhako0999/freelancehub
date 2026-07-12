class TaskReminderJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Task reminder job started"

    overdue_tasks = Task
      .includes(project: :client)
      .where.not(status: "Completed")
      .where("due_date < ?", Date.current)

    due_soon_tasks = Task
      .includes(project: :client)
      .where.not(status: "Completed")
      .where(due_date: Date.current..(Date.current + 2.days))

    overdue_tasks.find_each do |task|
      Rails.logger.warn(
        "OVERDUE TASK: #{task.title} | " \
        "Project: #{task.project.name} | " \
        "Client: #{task.project.client.name} | " \
        "Due: #{task.due_date}"
      )

      TaskReminderMailer
        .with(task: task)
        .task_due_reminder
        .deliver_now
    end

    due_soon_tasks.find_each do |task|
      Rails.logger.info(
        "DUE SOON: #{task.title} | " \
        "Project: #{task.project.name} | " \
        "Client: #{task.project.client.name} | " \
        "Due: #{task.due_date}"
      )

      TaskReminderMailer
        .with(task: task)
        .task_due_reminder
        .deliver_now
    end

    Rails.logger.info(
      "Task reminder job completed: " \
      "#{overdue_tasks.count} overdue, " \
      "#{due_soon_tasks.count} due soon"
    )
  end
end
