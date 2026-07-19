class AttachmentsController < ApplicationController
    def destroy
        attachment = ActiveStorage::Attachment.find(params[:id])
        project = attachment.record
        
        unless project.is_a?(Project)
            raise ActiveRecord::RecordNotFound
        end    

        client = Current.user.clients.find(project.client_id)
        project = client.projects.find(project.id)

        attachment.purge

        redirect_to client_project_path(client, project), status: :see_other, notice: "File was successfully removed."
    end    
end
