require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  let(:user) { create_user(email: 'user@example.com', password: 'password123') }

  describe 'unauthenticated user' do
    it 'redirects to login when accessing settings' do
      get settings_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'authenticated user' do
    before do
      post session_path, params: { email: user.email, password: 'password123' }
    end

    describe 'GET /settings' do
      it 'displays the settings page' do
        get settings_path
        expect(response).to be_successful
        expect(response.body).to include('Settings')
      end

      it 'displays the user form with current values' do
        get settings_path
        expect(response.body).to include(user.first_name)
        expect(response.body).to include(user.city)
      end

      it 'displays all editable fields' do
        get settings_path
        expect(response.body).to include('first_name')
        expect(response.body).to include('last_name')
        expect(response.body).to include('date_of_birth')
        expect(response.body).to include('gender')
        expect(response.body).to include('occupation')
        expect(response.body).to include('hobbies')
        expect(response.body).to include('likes')
        expect(response.body).to include('dislikes')
        expect(response.body).to include('street')
        expect(response.body).to include('city')
        expect(response.body).to include('state')
        expect(response.body).to include('zip_code')
        expect(response.body).to include('country')
      end
    end

    describe 'Credentials subpage' do
      it 'redirects to login when unauthenticated user visits credentials page' do
        delete session_path
        get credentials_settings_path
        expect(response).to redirect_to(login_path)
      end

      it 'shows a link to change email or password on the settings page' do
        get settings_path
        expect(response.body).to include('Change email or password')
        expect(response.body).to include(credentials_settings_path)
      end

      it 'renders the credentials page for an authenticated user' do
        get credentials_settings_path
        expect(response).to be_successful
        expect(response.body).to include('Change Email or Password')
        expect(response.body).to include('Current password')
      end

      it 'updates email when current password is correct and allows login with new email only' do
        post session_path, params: { email: user.email, password: 'password123' }
        expect(session[:user_id]).to eq(user.id)

        patch credentials_settings_path, params: {
          current_password: 'password123',
          user: { email: 'new_email@example.com' }
        }

        expect(response).to redirect_to(settings_path)
        follow_redirect!
        expect(response.body).to include('Account credentials updated successfully')

        user.reload
        expect(user.email).to eq('new_email@example.com')

        delete session_path

        post session_path, params: { email: 'user@example.com', password: 'password123' }
        expect(response.body).to include('Invalid email or password')

        post session_path, params: { email: 'new_email@example.com', password: 'password123' }
        expect(response).to redirect_to(root_path)
      end

      it 'updates password when current password is correct and only new password works for login' do
        patch credentials_settings_path, params: {
          current_password: 'password123',
          user: { password: 'newpass456', password_confirmation: 'newpass456' }
        }

        expect(response).to redirect_to(settings_path)

        delete session_path

        post session_path, params: { email: user.email, password: 'password123' }
        expect(response.body).to include('Invalid email or password')

        post session_path, params: { email: user.email, password: 'newpass456' }
        expect(response).to redirect_to(root_path)
      end

      it 'does not update credentials if current password is wrong' do
        original_email = user.email
        patch credentials_settings_path, params: {
          current_password: 'wrong',
          user: { email: 'bad_change@example.com', password: 'whatever123', password_confirmation: 'whatever123' }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Current password')
        user.reload
        expect(user.email).to eq(original_email)
        expect(user.authenticate('password123')).to be_truthy
      end
    end

    describe 'PATCH /settings' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            user: {
              first_name: 'Jane',
              last_name: 'Smith',
              date_of_birth: '1995-05-20',
              gender: 'Female',
              occupation: 'Designer',
              hobbies: 'Painting, Drawing',
              likes: 'Art, Nature',
              dislikes: 'Noise, Clutter',
              street: '456 Oak Ave',
              city: 'Portland',
              state: 'OR',
              zip_code: '97201',
              country: 'USA'
            }
          }
        end

        it 'updates the user profile' do
          patch settings_path, params: valid_params
          user.reload
          expect(user.first_name).to eq('Jane')
          expect(user.last_name).to eq('Smith')
          expect(user.city).to eq('Portland')
        end

        it 'redirects to settings page with success message' do
          patch settings_path, params: valid_params
          expect(response).to redirect_to(settings_path)
          follow_redirect!
          expect(response.body).to include('Settings updated successfully')
        end

        it 'updates only the specified fields (non-credential fields)' do
          original_email = user.email
          new_params = {
            user: {
              first_name: 'Updated',
              last_name: user.last_name,
              date_of_birth: user.date_of_birth,
              gender: user.gender,
              occupation: user.occupation,
              street: user.street,
              city: user.city,
              state: user.state,
              zip_code: user.zip_code,
              country: user.country
            }
          }
          patch settings_path, params: new_params
          user.reload
          expect(user.first_name).to eq('Updated')
          expect(user.email).to eq(original_email)
        end
      end

      context 'with invalid parameters' do
        it 'does not update user with blank first_name' do
          invalid_params = {
            user: {
              first_name: '',
              last_name: user.last_name,
              date_of_birth: user.date_of_birth,
              gender: user.gender,
              occupation: user.occupation,
              street: user.street,
              city: user.city,
              state: user.state,
              zip_code: user.zip_code,
              country: user.country
            }
          }
          patch settings_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
          user.reload
          expect(user.first_name).not_to eq('')
        end

        it 'displays error messages on validation failure' do
          invalid_params = {
            user: {
              first_name: '',
              last_name: user.last_name,
              date_of_birth: user.date_of_birth,
              gender: user.gender,
              occupation: user.occupation,
              street: user.street,
              city: user.city,
              state: user.state,
              zip_code: user.zip_code,
              country: user.country
            }
          }
          patch settings_path, params: invalid_params
          expect(response.body).to include('error')
        end
      end
    end
  end
end
