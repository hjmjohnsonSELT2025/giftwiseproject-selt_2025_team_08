class CreateEmailNotificationPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :email_notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_reminder_timing, default: nil
      t.string :gift_reminder_timing, default: nil
      t.boolean :event_reminders_enabled, default: false
      t.boolean :gift_reminders_enabled, default: false

      t.timestamps
    end
  end
end
