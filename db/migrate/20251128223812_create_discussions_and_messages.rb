class CreateDiscussionsAndMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :discussions do |t|
      t.references :event, null: false, foreign_key: true
      t.string :thread_type, null: false, default: 'public'
      t.timestamps
    end

    create_table :discussion_messages do |t|
      t.references :discussion, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end

    add_index :discussions, [:event_id, :thread_type], unique: true
  end
end
