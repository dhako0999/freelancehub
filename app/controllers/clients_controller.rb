class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
      clients_scope = Current.user.clients

      if params[:search].present?
        clients_scope = clients_scope.where(
          "name ILIKE :query OR company ILIKE :query OR email ILIKE :query",
          query: "%#{params[:search]}%"
        )
      end

      @pagy, @clients = pagy(:offset, clients_scope.order(:name), limit: 1)
  end

  def show
    @projects = @client.projects.order(created_at: :desc).limit(5)
  end

  def new
    @client = Current.user.clients.new
  end

  def create
    @client = Current.user.clients.new(client_params)

    if @client.save
      redirect_to clients_path, notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
     
  end

  def update
    attributes = client_params
    new_files = attributes.delete(:files)
  
    @client.assign_attributes(attributes)
  
    @client.files.attach(new_files) if new_files.present?
  
    if @client.save
      redirect_to client_path(@client),
                  notice: "Client was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy

      @client.destroy

      redirect_to clients_path, status: :see_other, notice: "Client was successfully deleted."
  end

  private

  def set_client
    @client = Current.user.clients.find(params[:id])
  end  

  def client_params
    params.require(:client).permit(
      :name, 
      :email, 
      :company, 
      :phone, 
      :notes,
      :industry,
      :service_type,
      :status,
      :website,
      files: []
    )
  end
end
