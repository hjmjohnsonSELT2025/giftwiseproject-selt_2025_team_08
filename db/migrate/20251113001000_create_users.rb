class CreateUsers < ActiveRecord::Migration[7.1]
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps
    end

    add_index :users, :email, unique: true
  end

  def down
    remove_index :users, :email if index_exists?(:users, :email)
    drop_table :users if table_exists?(:users)
  end
end
