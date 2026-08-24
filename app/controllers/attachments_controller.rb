class AttachmentsController < ApplicationController
    def destroy
      attachment = ActiveStorage::Attachment.find(params[:id])
      record = attachment.record
  
      case record
      when Project
        client = Current.user.clients.find(record.client_id)
        project = client.projects.find(record.id)
  
        attachment.purge
  
        redirect_to client_project_path(client, project),
                    status: :see_other,
                    notice: "File was successfully removed."
  
      when Client
        client = Current.user.clients.find(record.id)
  
        attachment.purge
  
        redirect_to client_path(client),
                    status: :see_other,
                    notice: "File was successfully removed."
  
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end
