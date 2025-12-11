require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'GET /registrations/new' do
    it 'renders the signup page' do
      get new_registration_path
      expect(response).to be_successful
      expect(response.body).to include('Create your account')
    end

    it 'provides a new user form' do
      get new_registration_path
      expect(response.body).to include('email')
      expect(response.body).to include('password')
      expect(response.body).to include('first_name')
      expect(response.body).to include('last_name')
    end
  end

  describe 'POST /registrations (create)' do
    def valid_signup_params
      {
        user: {
          email: 'newuser@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'John',
          last_name: 'Doe',
          date_of_birth: '1990-01-15',
          gender: 'Male',
          occupation: 'Software Engineer',
          hobbies: 'Reading, Gaming, Hiking',
          likes: 'Coffee, Music, Travel',
          dislikes: 'Crowds, Spicy food, Delays',
          street: '123 Main St',
          city: 'Springfield',
          state: 'IL',
          zip_code: '62701',
          country: 'USA'
        }
      }
    end

    context 'with valid parameters' do
      let(:valid_params) { valid_signup_params }

      it 'creates a new user' do
        expect {
          post registrations_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'stores all profile information' do
        post registrations_path, params: valid_params
        user = User.last
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
        expect(user.date_of_birth).to eq(Date.parse('1990-01-15'))
        expect(user.gender).to eq('Male')
        expect(user.occupation).to eq('Software Engineer')
        expect(user.street).to eq('123 Main St')
        expect(user.city).to eq('Springfield')
        expect(user.state).to eq('IL')
        expect(user.zip_code).to eq('62701')
        expect(user.country).to eq('USA')
      end

      it 'redirects to login page' do
        post registrations_path, params: valid_params
        expect(response).to redirect_to(login_path)
      end

      it 'displays success message on login page' do
        post registrations_path, params: valid_params
        follow_redirect!
        expect(response.body).to include('Account created successfully')
      end

      it 'stores email correctly (lowercased)' do
        post registrations_path, params: { 
          user: valid_params[:user].merge(email: 'NewUser@Example.com')
        }
        user = User.last
        expect(user.email).to eq('newuser@example.com')
      end
    end

    context 'with invalid parameters' do
      context 'missing required profile fields' do
        it 'does not create a user without first_name' do
          params = valid_signup_params
          params[:user].delete(:first_name)
          expect {
            post registrations_path, params: params
          }.not_to change(User, :count)
        end

        it 'does not create a user without last_name' do
          params = valid_signup_params
          params[:user].delete(:last_name)
          expect {
            post registrations_path, params: params
          }.not_to change(User, :count)
        end

        it 'does not create a user without date_of_birth' do
          params = valid_signup_params
          params[:user].delete(:date_of_birth)
          expect {
            post registrations_path, params: params
          }.not_to change(User, :count)
        end

        it 'does not create a user without gender' do
          params = valid_signup_params
          params[:user].delete(:gender)
          expect {
            post registrations_path, params: params
          }.not_to change(User, :count)
        end

        it 'does not create a user without address fields' do
          params = valid_signup_params
          params[:user].delete(:street)
          expect {
            post registrations_path, params: params
          }.not_to change(User, :count)
        end

        it 're-renders the signup form' do
          params = valid_signup_params
          params[:user].delete(:first_name)
          post registrations_path, params: params
          expect(response).to render_template('registrations/new')
        end
      end

      context 'missing email' do
        it 'does not create a user' do
          params = valid_signup_params
          params[:user].delete(:email)
          expect {
            post registrations_path, params: params
          }.not_to change(User, :count)
        end

        it 're-renders the signup form' do
          params = valid_signup_params
          params[:user].delete(:email)
          post registrations_path, params: params
          expect(response).to render_template('registrations/new')
        end
      end

      context 'password too short' do
        it 'does not create a user' do
          expect {
            post registrations_path, params: {
              user: valid_signup_params[:user].merge(
                password: 'short',
                password_confirmation: 'short'
              )
            }
          }.not_to change(User, :count)
        end

        it 're-renders the signup form' do
          post registrations_path, params: {
            user: valid_signup_params[:user].merge(
              password: 'short',
              password_confirmation: 'short'
            )
          }
          expect(response).to render_template('registrations/new')
        end
      end

      context 'password mismatch' do
        it 'does not create a user' do
          expect {
            post registrations_path, params: {
              user: valid_signup_params[:user].merge(
                password: 'password123',
                password_confirmation: 'different'
              )
            }
          }.not_to change(User, :count)
        end
      end

      context 'duplicate email' do
        before do
          User.create!(
            email: 'taken@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            first_name: 'Existing',
            last_name: 'User',
            date_of_birth: '1990-01-01',
            gender: 'Male',
            occupation: 'Engineer',
            street: '123 Main',
            city: 'City',
            state: 'ST',
            zip_code: '12345',
            country: 'USA'
          )
        end

        it 'does not create a duplicate user' do
          expect {
            post registrations_path, params: {
              user: valid_signup_params[:user].merge(email: 'taken@example.com')
            }
          }.not_to change(User, :count)
        end

        it 'is case-insensitive for email uniqueness' do
          expect {
            post registrations_path, params: {
              user: valid_signup_params[:user].merge(email: 'TAKEN@EXAMPLE.COM')
            }
          }.not_to change(User, :count)
        end
      end
    end
  end
end
