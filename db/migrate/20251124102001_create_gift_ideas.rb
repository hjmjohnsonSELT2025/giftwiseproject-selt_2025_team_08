class CreateGiftIdeas < ActiveRecord::Migration[7.1]
  def change
    create_table :gift_ideas do |t|
      t.references :recipient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :idea, null: false
      t.decimal :estimated_price
      t.boolean :favorited, default: false

      t.timestamps
    end
  end
end
