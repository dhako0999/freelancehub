class AttachmentsController < ApplicationController
    def destroy
        attachment = ActiveStorage::Attachment.find(params[:id])
        project = attachment.record
        client = project.client

        attachment.purge

        redirect_to client_project_path(client, project), notice: "File was successfully removed."
    end    
end
