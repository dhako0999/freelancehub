module ApplicationHelper
    module ApplicationHelper
      def status_badge(status)
        classes = case status
        when "Completed"
            "bg-emerald-100 text-emerald-800 ring-emerald-200"
        when "In Progress"
            "bg-blue-100 text-blue-800 ring-blue-200"
        when "Blocked"
            "bg-red-100 text-red-800 ring-red-200"
        else
            "bg-slate-100 text-slate-800 ring-slate-200"
        end

        content_tag(:span, status, class: "rounded-full px-3 py-1 text-sm font-semibold ring-1 #{classes}")
      end
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
end
