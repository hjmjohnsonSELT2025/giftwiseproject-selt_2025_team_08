class AddDeletedAtToGiftsForRecipients < ActiveRecord::Migration[7.1]
  def change
    add_column :gifts_for_recipients, :deleted_at, :datetime
  end
end
