class AiConversationsController < ApplicationController
    before_action :set_conversation, only: %i[show]
  
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
  
    private
  
    def set_conversation
      @conversation = Current.user
        .ai_conversations
        .find(params[:id])
    end
  end