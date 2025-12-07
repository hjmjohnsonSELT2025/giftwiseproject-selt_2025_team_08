class AddLinkAndNoteToGiftIdeas < ActiveRecord::Migration[7.1]
  def change
    add_column :gift_ideas, :link, :string
    add_column :gift_ideas, :note, :string, limit: 255
  end
end
