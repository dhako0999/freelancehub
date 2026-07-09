class ClientsController < ApplicationController
  def index
    clients_scope =
      if params[:search].present?
        Client.where(
          "name ILIKE :query OR company ILIKE :query OR email ILIKE :query",
          query: "%#{params[:search]}%"
        )
      else
        Client.all
      end

    @pagy, @clients = pagy(:offset, clients_scope.order(:name), limit: 1)
  end

  def show
    @client = Client.find(params[:id])
    @projects = @client.projects.order(created_at: :desc).limit(5)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to clients_path, notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
     @client = Client.find(params[:id])
  end

  def update
     @client = Client.find(params[:id])

     if @client.update(client_params)
       redirect_to client_path(@client), notice: "Client was successfully updated."
     else
       render :edit, status: :unprocessable_entity
     end
  end

  def destroy
      @client = Client.find(params[:id])

      @client.destroy
      redirect_to clients_path, notice: "Client was successfully deleted."
  end

  private

  def client_params
    params.require(:client).permit(:name, :email, :company, :phone, :notes)
  end
end
