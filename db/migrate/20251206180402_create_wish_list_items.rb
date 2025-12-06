class CreateWishListItems < ActiveRecord::Migration[7.1]
  def change
    create_table :wish_list_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :url
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end

    add_index :wish_list_items, [:user_id, :name], unique: true
  end
end
