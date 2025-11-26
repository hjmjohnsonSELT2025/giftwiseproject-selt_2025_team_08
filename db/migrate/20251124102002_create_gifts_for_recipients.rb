class CreateGiftsForRecipients < ActiveRecord::Migration[7.1]
  def change
    create_table :gifts_for_recipients do |t|
      t.references :recipient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :idea, null: false
      t.decimal :price
      t.date :gift_date

      t.timestamps
    end
  end
end
