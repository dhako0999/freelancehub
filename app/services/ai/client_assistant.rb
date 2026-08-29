module Ai
  class ClientAssistant
    def initialize(user:, messages: [])
      @user = user
      @messages = messages
      @client = OpenAI::Client.new
    end

    def ask(question)
      response = @client.responses.create(
        model: "gpt-5.2",
        input: [
          {
            role: "system",
            content: system_prompt
          },
          *conversation_history,
          {
            role: "user",
            content: question
          }
        ]
      )

      response.output_text
    end

    def generate_title(question)
      response = @client.responses.create(
        model: "gpt-5.2",
        input: [
          {
            role: "system",
            content: <<~PROMPT
              Create a short title for an AI CRM conversation.
    
              Requirements:
              - Maximum 6 words
              - No quotation marks
              - No period at the end
              - Be specific to the user's question
              - Return only the title
            PROMPT
          },
          {
            role: "user",
            content: question
          }
        ]
      )
    
      response.output_text.strip
    end

    def stream_answer(question, &block)
      stream = @client.responses.stream(
        model: "gpt-5.2",
        input: [
          {
            role: "system",
            content: system_prompt
          },
          *conversation_history,
          {
            role: "user",
            content: question
          }
        ]
      )
    
      stream.each do |event|
        next unless event.is_a?(
          OpenAI::Streaming::ResponseTextDeltaEvent
        )
    
        block.call(event.delta)
      end
    end

    private

    def conversation_history
      @messages.map do |message|
        {
          role: message.role,
          content: message.content
        }
      end
    end

    def system_prompt
      <<~PROMPT
        You are an AI assistant for a freelance CRM application.

        Answer questions using only the CRM data supplied below.

        Use the prior conversation messages to understand follow-up
        questions and references such as "it", "that project",
        "that client", or "those tasks".

        If the answer is not supported by the supplied CRM data,
        say that the information is not available.

        CRM DATA:

        #{crm_context}
      PROMPT
    end

    def crm_context
      @user.clients
           .includes(projects: :tasks)
           .map { |client| client_context(client) }
           .join("\n\n")
    end

    def client_context(client)
      projects = client.projects.map do |project|
        project_context(project)
      end.join("\n")

      <<~TEXT
        Client:
        Name: #{client.name}
        Company: #{client.company}
        Email: #{client.email}
        Notes: #{client.notes}

        Projects:
        #{projects.presence || "No projects"}
      TEXT
    end

    def project_context(project)
      tasks = project.tasks.map do |task|
        <<~TASK
          - #{task.title}
            Status: #{task.status}
            Priority: #{task.priority}
            Due date: #{task.due_date || "Not specified"}
        TASK
      end.join

      <<~TEXT
        Project: #{project.name}
        Status: #{project.status}
        Deadline: #{project.deadline || "Not specified"}
        Description: #{project.description}

        Tasks:
        #{tasks.presence || "No tasks"}
      TEXT
    end
  end
end