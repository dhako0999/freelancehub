class AiMessagesController < ApplicationController
    def create
      conversation = Current.user
        .ai_conversations
        .find(params[:ai_conversation_id])
  
      question = params[:content].to_s.strip
  
      if question.blank?
        redirect_to ai_conversation_path(conversation),
                    alert: "Enter a question."
        return
      end
  
      previous_messages = conversation
        .ai_messages
        .order(:created_at)
        .to_a
  
      conversation.ai_messages.create!(
        role: "user",
        content: question
      )
  
      answer = Ai::ClientAssistant
        .new(
          user: Current.user,
          messages: previous_messages
        )
        .ask(question)
  
      conversation.ai_messages.create!(
        role: "assistant",
        content: answer
      )
  
      conversation.touch
  
      redirect_to ai_conversation_path(conversation)
    rescue OpenAI::Errors::APIError => error
      Rails.logger.error(
        "OpenAI request failed: #{error.class}: #{error.message}"
      )
  
      redirect_to ai_conversation_path(conversation),
                  alert: "The AI assistant is temporarily unavailable."
    end
  end