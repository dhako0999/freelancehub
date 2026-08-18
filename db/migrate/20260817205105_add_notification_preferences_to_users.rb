class AddNotificationPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :task_reminders_enabled, :boolean
    add_column :users, :reminder_days_before, :integer
  end
end
