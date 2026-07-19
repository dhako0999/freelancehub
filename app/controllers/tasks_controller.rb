class TasksController < ApplicationController
  before_action :set_client
  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = @project.tasks.order(created_at: :desc)
  end

  def show
  end

  def new
    @task = @project.tasks.new
  end

  def create
    @task = @project.tasks.new(task_params)

    if @task.save
      redirect_to client_project_task_path(@client, @project, @task), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to client_project_task_path(@client, @project, @task), notice: "Task was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy

    redirect_to client_project_path(@client, @project), notice: "Task was successfully deleted."
  end

  private

  def set_client
    @client = Current.user.clients.find(params[:client_id])
  end

  def set_project
    @project = @client.projects.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :status, :priority, :due_date, :description)
  end
end
