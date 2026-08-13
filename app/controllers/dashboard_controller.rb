class DashboardController < ApplicationController
  def index
    @clients = Current.user.clients

    @projects = Project.joins(:client)
                       .where(clients: { user_id: Current.user.id })

    @tasks = Task.joins(project: :client)
                 .where(clients: { user_id: Current.user.id })

    @upcoming_tasks = @tasks
                 .where.not(status: "Completed")
                 .where(due_date: Date.current..(Date.current + 7.days))
                 .includes(project: :client)
                 .order(:due_date)
                 .limit(5)        

    @total_clients = @clients.count
    @total_projects = @projects.count
    @total_tasks = @tasks.count

    @active_projects = @projects.where(status: "Active").count

    @completed_tasks = @tasks.where(status: "Completed").count
    @open_tasks = @tasks.where.not(status: "Completed").count

    @overdue_tasks = @tasks
                       .where.not(status: "Completed")
                       .where("due_date < ?", Date.current)
                       .count

    @due_soon_tasks = @tasks
                        .where.not(status: "Completed")
                        .where(due_date: Date.current..(Date.current + 2.days))
                        .count

    @recent_clients = @clients
                        .order(created_at: :desc)
                        .limit(5)

    @recent_projects = @projects
                         .includes(:client)
                         .order(created_at: :desc)
                         .limit(5)

    @recent_tasks = @tasks
                      .includes(project: :client)
                      .order(created_at: :desc)
                      .limit(5)

  end
end
