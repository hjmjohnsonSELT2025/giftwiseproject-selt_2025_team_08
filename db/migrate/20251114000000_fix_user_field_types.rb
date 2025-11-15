class FixUserFieldTypes < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :date_of_birth, :date
  end
end
