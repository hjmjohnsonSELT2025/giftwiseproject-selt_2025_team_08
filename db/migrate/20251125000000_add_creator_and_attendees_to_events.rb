class AddCreatorAndAttendeesToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :creator_id, :integer, null: false
    add_column :events, :description, :text unless column_exists?(:events, :description)
    
    create_table :event_attendees do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :event_attendees, [:event_id, :user_id], unique: true
    add_foreign_key :events, :users, column: :creator_id
  end
end
