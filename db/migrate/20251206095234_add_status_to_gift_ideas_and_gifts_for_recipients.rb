class AddStatusToGiftIdeasAndGiftsForRecipients < ActiveRecord::Migration[7.1]
  def change
    add_column :gift_ideas, :status, :string, default: 'idea'
    add_column :gifts_for_recipients, :status, :string, default: 'idea'
    
    add_index :gift_ideas, :status
    add_index :gifts_for_recipients, :status
  end
end
