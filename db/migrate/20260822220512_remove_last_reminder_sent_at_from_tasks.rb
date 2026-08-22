class RemoveLastReminderSentAtFromTasks < ActiveRecord::Migration[8.1]
  def change
    remove_column :tasks, :last_reminder_sent_at, :datetime
  end
end
