class FixUserFieldTypes < ActiveRecord::Migration[7.1]
  def change
    # This migration is a no-op for fresh databases
    # The date_of_birth column is created correctly as :date in migration 20251115003658_add_profile_fields_to_users
    # This migration only exists to fix existing databases where date_of_birth was created as a string
    if table_exists?(:users) && column_exists?(:users, :date_of_birth)
      column = columns(:users).find { |c| c.name == 'date_of_birth' }
      if column && column.type != :date
        change_column :users, :date_of_birth, :date
      end
    end
  end
end
