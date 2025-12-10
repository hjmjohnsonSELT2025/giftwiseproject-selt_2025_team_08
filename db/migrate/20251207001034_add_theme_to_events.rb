class AddThemeToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :theme, :string
  end
end
