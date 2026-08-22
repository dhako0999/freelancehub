class AddLastReminderSentAtToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :last_reminder_sent_at, :datetime
  end
end
