# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create test users
test_user = User.find_or_create_by!(email: 'steve@gmail.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.first_name = 'Steve'
  user.last_name = 'Johnson'
  user.date_of_birth = Date.new(1990, 5, 15)
  user.gender = 'Male'
  user.occupation = 'Software Engineer'
  user.hobbies = 'Reading, Gaming, Coffee'
  user.likes = 'Technology, Programming, Coffee'
  user.dislikes = 'Bugs, Spam'
  user.street = '123 Main St'
  user.city = 'Austin'
  user.state = 'TX'
  user.zip_code = '78701'
  user.country = 'USA'
end

# Create some contact users
contact1 = User.find_or_create_by!(email: 'alice@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.first_name = 'Alice'
  user.last_name = 'Smith'
  user.date_of_birth = Date.new(1988, 3, 22)
  user.gender = 'Female'
  user.occupation = 'Designer'
  user.hobbies = 'Painting, Yoga, Cooking'
  user.likes = 'Art, Nature'
  user.dislikes = 'Noise'
  user.street = '456 Oak Ave'
  user.city = 'Denver'
  user.state = 'CO'
  user.zip_code = '80202'
  user.country = 'USA'
end

contact2 = User.find_or_create_by!(email: 'bob@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.first_name = 'Bob'
  user.last_name = 'Wilson'
  user.date_of_birth = Date.new(1992, 7, 10)
  user.gender = 'Male'
  user.occupation = 'Teacher'
  user.hobbies = 'Reading, Hiking, Photography'
  user.likes = 'Books, Outdoors'
  user.dislikes = 'Traffic'
  user.street = '789 Pine Ln'
  user.city = 'Portland'
  user.state = 'OR'
  user.zip_code = '97201'
  user.country = 'USA'
end

# Add contacts to test user
Contact.find_or_create_by!(user_id: test_user.id, contact_user_id: contact1.id)
Contact.find_or_create_by!(user_id: test_user.id, contact_user_id: contact2.id)

puts "Seed data created successfully!"
