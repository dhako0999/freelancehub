module ApplicationHelper
    def status_badge(status)
      classes = case status
      when "completed"
                  "bg-green-100 text-green-800"
      when "in_progress"
                  "bg-blue-100 text-blue-800"
      else
                  "bg-slate-100 text-slate-800"
      end

      tag.span(status.titleize, class: classes)
    end

    def priority_badge(priority)
      classes = case priority
      when "High"
                  "bg-red-100 text-red-800 ring-red-200"
      when "Medium"
                  "bg-amber-100 text-amber-800 ring-amber-200"
      else
                  "bg-emerald-100 text-emerald-800 ring-emerald-200"
      end

      content_tag(:span, priority, class: "rounded-full px-3 py-1 text-sm font-semibold ring-1 #{classes}")
    end

    def overdue_task?(task)
        task.due_date.present? && task.due_date < Date.current && task.status != "Completed"
    end

    def task_due_soon?(task)
        task.due_date.present? && Date.current >= task.due_date - 2.days && Date.current <= task.due_date && task.status != "Completed"
    end

    def markdown(text)
      html = Kramdown::Document.new(text.to_s).to_html
  
      sanitize(
        html,
        tags: %w[
          p br strong em
          h1 h2 h3 h4
          ul ol li
          blockquote
          code pre
          a
        ],
        attributes: %w[href title]
      )
    end


    def ai_suggested_prompts(user)
      prompts = []
    
      if user.clients.exists?
        prompts << "Summarize my current clients."
      end
    
      if user.clients.joins(:projects).exists?
        prompts << "What projects am I currently working on?"
        prompts << "Which projects have upcoming deadlines?"
      end
    
      if user.clients.joins(projects: :tasks).exists?
        prompts << "Which tasks are overdue?"
        prompts << "What are my highest-priority tasks?"
      end
    
      fallback_prompts = [
        "What should I focus on today?",
        "What information is available in my CRM?",
        "Help me review my client workload.",
        "What should I follow up on next?"
      ]

      (prompts + fallback_prompts).uniq.first(4)


    end
end
