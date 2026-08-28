class AiConversationsController < ApplicationController
    before_action :set_conversation, only: %i[show update destroy]
  
    def index
      @conversations = Current.user
        .ai_conversations
        .order(updated_at: :desc)
    end
  
    def show
      @messages = @conversation
        .ai_messages
        .order(:created_at)
    end
  
    def create
      conversation = Current.user.ai_conversations.create!(
        title: "New Conversation"
      )
  
      redirect_to ai_conversation_path(conversation)
    end

    def update
      if @conversation.update(conversation_params)
        redirect_to ai_conversation_path(@conversation),
                    notice: "Conversation was successfully renamed."
      else
        @messages = @conversation.ai_messages.order(:created_at)
        render :show, status: :unprocessable_entity
      end
    end
    
    def destroy
      @conversation.destroy
    
      redirect_to ai_conversations_path,
                  status: :see_other,
                  notice: "Conversation was successfully deleted."
    end
  
    private
  
    def set_conversation
      @conversation = Current.user
        .ai_conversations
        .find(params[:id])
    end

    def conversation_params
      params.require(:ai_conversation).permit(:title)
    end

    def set_conversation
      @conversation = Current.user
        .ai_conversations
        .find(params[:id])
    end
  end