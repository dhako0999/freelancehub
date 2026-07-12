class TaskReminderMailer < ApplicationMailer
  def task_due_reminder
    @task = params[:task]
    @project = @task.project
    @client = @project.client

    mail(
      to: @client.email,
      subject: "Task Reminder: #{@task.title} is due soon"
    )
  end
end
