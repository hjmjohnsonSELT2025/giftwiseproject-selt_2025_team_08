class CreateSentReminders < ActiveRecord::Migration[7.1]
  def change
    create_table :sent_reminders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :reminder_type, null: false
      t.string :timing, null: false

      t.timestamps
    end

    add_index :sent_reminders, [:user_id, :event_id, :reminder_type], unique: true, name: 'index_sent_reminders_uniqueness'
  end
end
