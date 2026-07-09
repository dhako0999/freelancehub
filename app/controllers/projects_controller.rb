class ProjectsController < ApplicationController
  before_action :set_client
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = @client.projects
  end

  def show
    @tasks = @project.tasks.order(created_at: :desc).limit(5)
    @total_tasks = @project.tasks.count
    @completed_tasks = @project.tasks.where(status: "Completed").count
    @remaining_tasks = @total_tasks - @completed_tasks
    @progress_percentage = @total_tasks.zero? ? 0: ((@completed_tasks.to_f / @total_tasks) * 100).round

  end

  def new
    @project = @client.projects.new
  end

  def create
    @project = @client.projects.new(project_params)

    if @project.save
      redirect_to client_project_path(@client, @project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end    
  end  

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to client_project_path(@client, @project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end    
  
  def destroy
    @project.destroy

    redirect_to client_path(@client), notice: "Project was successfully deleted."
  end
  
  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_project
    @project = @client.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :status, :start_date, :deadline, :budget, :description)
  end
end
