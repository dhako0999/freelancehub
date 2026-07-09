class DashboardController < ApplicationController
  def index
    @total_clients = Client.count
    @total_projects = Project.count
    @total_tasks = Task.count

    @active_projects = Project.where(status: "Active").count
    @completed_tasks = Task.where(status: "Completed").count
    @open_tasks = Task.where.not(status: "Completed").count

    @overdue_tasks = Task.where.not(status: "Completed")
    .where("due_date < ?", Date.current).count

    @due_soon_tasks = Task.where.not(status: "Completed")
    .where(due_date: Date.current..(Date.current + 2.days))
    .count

    @recent_clients = Client.order(created_at: :desc).limit(5)
    @recent_projects = Project.includes(:client).order(created_at: :desc).limit(5)
    @recent_tasks = Task.includes(project: :client).order(created_at: :desc).limit(5)
  end
end
