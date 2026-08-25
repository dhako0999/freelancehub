class AssistantController < ApplicationController
    def show
    end
  
    def create
      question = params[:question].to_s.strip
  
      if question.blank?
        flash.now[:alert] = "Enter a question."
        return render :show, status: :unprocessable_entity
      end
  
      @question = question
  
      @answer = Ai::ClientAssistant
        .new(user: Current.user)
        .ask(question)
  
      render :show
    rescue OpenAI::Errors::APIError => error
      Rails.logger.error(
        "OpenAI request failed: #{error.class}: #{error.message}"
      )
  
      flash.now[:alert] = "The AI assistant is temporarily unavailable."
  
      render :show, status: :service_unavailable
    end
  end