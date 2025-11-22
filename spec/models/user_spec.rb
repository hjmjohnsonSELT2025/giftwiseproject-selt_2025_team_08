require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'John',
      last_name: 'Doe',
      date_of_birth: '1990-01-15',
      gender: 'Male',
      occupation: 'Engineer',
      hobbies: 'Reading, Gaming',
      likes: 'Coffee, Music',
      dislikes: 'Crowds, Spicy food',
      street: '123 Main St',
      city: 'Springfield',
      state: 'IL',
      zip_code: '62701',
      country: 'USA'
    }
  end

  describe 'email validations' do
    it 'validates presence of email' do
      user = User.new(valid_attributes.except(:email))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'requires unique email (case-insensitive)' do
      User.create!(valid_attributes)
      user = User.new(valid_attributes.merge(email: 'TEST@EXAMPLE.COM'))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'downcases email before saving' do
      user = User.create!(valid_attributes.merge(email: 'TEST@EXAMPLE.COM'))
      expect(user.email).to eq('test@example.com')
    end
  end

  describe 'password validations' do
    it 'authenticates with correct password' do
      user = User.create!(valid_attributes)
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'requires minimum password length' do
      user = User.new(valid_attributes.merge(password: 'short', password_confirmation: 'short'))
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe 'profile field validations' do
    it 'validates presence of first_name' do
      user = User.new(valid_attributes.except(:first_name))
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to be_present
    end

    it 'validates presence of last_name' do
      user = User.new(valid_attributes.except(:last_name))
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to be_present
    end

    it 'validates presence of date_of_birth' do
      user = User.new(valid_attributes.except(:date_of_birth))
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to be_present
    end

    it 'validates presence of gender' do
      user = User.new(valid_attributes.except(:gender))
      expect(user).not_to be_valid
      expect(user.errors[:gender]).to be_present
    end

    it 'validates presence of occupation' do
      user = User.new(valid_attributes.except(:occupation))
      expect(user).not_to be_valid
      expect(user.errors[:occupation]).to be_present
    end
  end

  describe 'address validations' do
    %i[street city state zip_code country].each do |field|
      it "validates presence of #{field}" do
        user = User.new(valid_attributes.except(field))
        expect(user).not_to be_valid
        expect(user.errors[field]).to be_present
      end
    end
  end

  describe 'interest fields' do
    it 'stores hobbies, likes, and dislikes' do
      user = User.create!(valid_attributes)
      expect(user.hobbies).to eq('Reading, Gaming')
      expect(user.likes).to eq('Coffee, Music')
      expect(user.dislikes).to eq('Crowds, Spicy food')
    end
  end

  describe 'user creation' do
    it 'creates a valid user with all attributes' do
      user = User.create!(valid_attributes)
      expect(user).to be_persisted
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
      expect(user.street).to eq('123 Main St')
      expect(user.city).to eq('Springfield')
    end
  end
end
