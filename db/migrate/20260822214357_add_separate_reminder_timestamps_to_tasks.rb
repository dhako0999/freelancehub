class AddSeparateReminderTimestampsToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :due_soon_reminder_sent_at, :datetime
    add_column :tasks, :overdue_reminder_sent_at, :datetime
  end
end
