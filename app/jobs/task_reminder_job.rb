class TaskReminderJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Task reminder job started"

    total_overdue = 0
    total_due_soon = 0

    User.where(task_reminders_enabled: true).find_each do |user|
      reminder_date = Date.current + user.reminder_days_before.days

      overdue_tasks = Task
        .joins(project: :client)
        .includes(project: :client)
        .where(clients: { user_id: user.id })
        .where.not(status: "Completed")
        .where("tasks.due_date < ?", Date.current)

      due_soon_tasks = Task
        .joins(project: :client)
        .includes(project: :client)
        .where(clients: { user_id: user.id })
        .where.not(status: "Completed")
        .where(due_date: reminder_date)

      overdue_tasks.find_each do |task|
        next if overdue_reminder_sent_today?(task)

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

        task.update!(overdue_reminder_sent_at: Time.current)

        total_overdue += 1
      end

      due_soon_tasks.find_each do |task|
        next if due_soon_reminder_sent?(task)

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

        task.update!(due_soon_reminder_sent_at: Time.current)

        total_due_soon += 1
      end
    end

    Rails.logger.info(
      "Task reminder job completed: " \
      "#{total_overdue} overdue, " \
      "#{total_due_soon} due soon"
    )
  end

  private

  def overdue_reminder_sent_today?(task)
    task.overdue_reminder_sent_at&.to_date == Date.current
  end

  def due_soon_reminder_sent?(task)
    task.due_soon_reminder_sent_at.present?
  end
end