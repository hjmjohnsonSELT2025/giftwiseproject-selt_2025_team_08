class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string, null: false
    add_column :users, :last_name, :string, null: false
    add_column :users, :date_of_birth, :date, null: false
    add_column :users, :gender, :string, null: false
    add_column :users, :occupation, :string, null: false
    add_column :users, :hobbies, :text
    add_column :users, :likes, :text
    add_column :users, :dislikes, :text
    add_column :users, :street, :string, null: false
    add_column :users, :city, :string, null: false
    add_column :users, :state, :string, null: false
    add_column :users, :zip_code, :string, null: false
    add_column :users, :country, :string, null: false
  end
end
