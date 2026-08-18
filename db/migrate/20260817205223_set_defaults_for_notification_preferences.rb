class SetDefaultsForNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users,
                          :task_reminders_enabled,
                          from: nil,
                          to: true

    change_column_default :users,
                          :reminder_days_before,
                          from: nil,
                          to: 2

    User.where(task_reminders_enabled: nil)
        .update_all(task_reminders_enabled: true)

    User.where(reminder_days_before: nil)
        .update_all(reminder_days_before: 2)

    change_column_null :users,
                       :task_reminders_enabled,
                       false

    change_column_null :users,
                       :reminder_days_before,
                       false
  end
end
