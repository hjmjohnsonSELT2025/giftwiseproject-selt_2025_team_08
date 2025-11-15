class AddNotNullConstraintsToUsers < ActiveRecord::Migration[7.1]
  def change
    User.where(first_name: nil).update_all(first_name: 'Unknown')
    User.where(last_name: nil).update_all(last_name: 'Unknown')
    User.where(date_of_birth: nil).update_all(date_of_birth: Date.new(1900, 1, 1))
    User.where(gender: nil).update_all(gender: 'Not specified')
    User.where(occupation: nil).update_all(occupation: 'Not specified')
    User.where(street: nil).update_all(street: 'Not provided')
    User.where(city: nil).update_all(city: 'Not provided')
    User.where(state: nil).update_all(state: 'Not provided')
    User.where(zip_code: nil).update_all(zip_code: '00000')
    User.where(country: nil).update_all(country: 'Not provided')

    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :users, :date_of_birth, false
    change_column_null :users, :gender, false
    change_column_null :users, :occupation, false
    change_column_null :users, :street, false
    change_column_null :users, :city, false
    change_column_null :users, :state, false
    change_column_null :users, :zip_code, false
    change_column_null :users, :country, false
  end
end
