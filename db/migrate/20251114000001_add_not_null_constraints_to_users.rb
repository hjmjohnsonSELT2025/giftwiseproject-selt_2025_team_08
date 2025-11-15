class AddNotNullConstraintsToUsers < ActiveRecord::Migration[7.1]
  def change
    # Only run if the columns exist (they're created in migration 20251115003658_add_profile_fields_to_users)
    # This migration is for existing databases that already have these columns
    return unless table_exists?(:users) && column_exists?(:users, :first_name)
    
    # Update existing records with null values
    if User.column_names.include?('first_name')
      User.where(first_name: nil).update_all(first_name: 'Unknown') if User.exists?
      User.where(last_name: nil).update_all(last_name: 'Unknown') if User.exists?
      User.where(date_of_birth: nil).update_all(date_of_birth: Date.new(1900, 1, 1)) if User.exists?
      User.where(gender: nil).update_all(gender: 'Not specified') if User.exists?
      User.where(occupation: nil).update_all(occupation: 'Not specified') if User.exists?
      User.where(street: nil).update_all(street: 'Not provided') if User.exists?
      User.where(city: nil).update_all(city: 'Not provided') if User.exists?
      User.where(state: nil).update_all(state: 'Not provided') if User.exists?
      User.where(zip_code: nil).update_all(zip_code: '00000') if User.exists?
      User.where(country: nil).update_all(country: 'Not provided') if User.exists?

      # Add not null constraints only if columns exist
      change_column_null :users, :first_name, false if column_exists?(:users, :first_name)
      change_column_null :users, :last_name, false if column_exists?(:users, :last_name)
      change_column_null :users, :date_of_birth, false if column_exists?(:users, :date_of_birth)
      change_column_null :users, :gender, false if column_exists?(:users, :gender)
      change_column_null :users, :occupation, false if column_exists?(:users, :occupation)
      change_column_null :users, :street, false if column_exists?(:users, :street)
      change_column_null :users, :city, false if column_exists?(:users, :city)
      change_column_null :users, :state, false if column_exists?(:users, :state)
      change_column_null :users, :zip_code, false if column_exists?(:users, :zip_code)
      change_column_null :users, :country, false if column_exists?(:users, :country)
    end
  end
end
