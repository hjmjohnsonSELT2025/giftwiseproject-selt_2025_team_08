class CreateRecipients < ActiveRecord::Migration[7.1]
  def change
    create_table :recipients do |t|
      t.references :event, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :age
      t.string :occupation
      t.text :hobbies
      t.text :likes
      t.text :dislikes

      t.timestamps
    end
  end
end
