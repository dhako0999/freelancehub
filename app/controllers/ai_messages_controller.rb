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
  
      assistant = Ai::ClientAssistant.new(
        user: Current.user,
        messages: previous_messages
      )
  
      answer = assistant.ask(question)
  
      if conversation.title == "New Conversation"
        conversation.update!(
          title: assistant.generate_title(question)
        )
      end
  
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

    
    def stream
      conversation = Current.user
        .ai_conversations
        .find(params[:ai_conversation_id])
    
      question = params[:content].to_s.strip
    
      if question.blank?
        head :unprocessable_entity
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
    
      assistant = Ai::ClientAssistant.new(
        user: Current.user,
        messages: previous_messages
      )
    
      response.headers["Content-Type"] = "text/event-stream"
      response.headers["Cache-Control"] = "no-cache"
    
      full_answer = +""
    
      self.response_body = Enumerator.new do |yielder|
        begin
          assistant.stream_answer(question) do |chunk|
            full_answer << chunk
    
            yielder << "data: #{chunk.to_json}\n\n"
          end
    
          assistant_message = conversation.ai_messages.create!(
            role: "assistant",
            content: full_answer
          )
    
          if conversation.title == "New Conversation"
            conversation.update!(
              title: assistant.generate_title(question)
            )
          end
    
          conversation.touch
    
          yielder << "event: done\ndata: #{{
            message_id: assistant_message.id
          }.to_json}\n\n"
        rescue OpenAI::Errors::APIError => error
          Rails.logger.error(
            "OpenAI streaming request failed: #{error.class}: #{error.message}"
          )
    
          yielder << "event: error\ndata: #{{
            message: "The AI assistant is temporarily unavailable."
          }.to_json}\n\n"
        end
      end
    rescue OpenAI::Errors::APIError => error
      Rails.logger.error(
        "OpenAI streaming request failed: #{error.class}: #{error.message}"
      )
    
      head :service_unavailable
    end

    def rendered
      conversation = Current.user
        .ai_conversations
        .find(params[:ai_conversation_id])
    
      message = conversation
        .ai_messages
        .find(params[:id])
    
      render html: helpers.markdown(message.content)
    end
    
  end