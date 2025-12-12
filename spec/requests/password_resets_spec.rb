require 'rails_helper'

RSpec.describe "Password resets", type: :request do
  let!(:user) { create_user(email: 'reset@example.com', password: 'oldpassword') }

  describe 'GET /password_resets/new' do
    it 'renders the request form' do
      get new_password_reset_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Forgot your password?')
    end
  end

  describe 'POST /password_resets' do
    it 'sends a reset email when the email exists' do
      expect {
        post password_resets_path, params: { email: user.email }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include('If that email address exists in our system')

      user.reload
      expect(user.reset_password_token).to be_present
      expect(user.reset_password_sent_at).to be_present
    end

    it "doesn't reveal non-existent emails and doesn't send mail" do
      expect {
        post password_resets_path, params: { email: 'unknown@example.com' }
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include('If that email address exists in our system')
    end
  end

  describe 'GET /password_resets/:token/edit' do
    it 'redirects for invalid token' do
      get edit_password_reset_path(token: 'not-a-real-token')
      expect(response).to redirect_to(new_password_reset_path)
      follow_redirect!
      expect(response.body).to include('Invalid password reset link')
    end
  end

  describe 'PATCH /password_resets/:token' do
    before do
      user.generate_password_reset!
    end

    it 'updates password successfully and clears token' do
      patch password_reset_path(token: user.reset_password_token), params: {
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include('Your password has been reset')

      user.reload
      expect(user.authenticate('newpassword')).to be_truthy
      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_sent_at).to be_nil
    end

    it 'renders edit when passwords are blank' do
      patch password_reset_path(token: user.reset_password_token), params: {
        password: '',
        password_confirmation: ''
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Password and confirmation are required')
    end

    it 'renders edit when confirmation does not match' do
      patch password_reset_path(token: user.reset_password_token), params: {
        password: 'newpassword',
        password_confirmation: 'different'
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Password confirmation does not match')
    end

    it 'rejects expired tokens' do
      user.update!(reset_password_sent_at: 3.hours.ago)

      patch password_reset_path(token: user.reset_password_token), params: {
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }

      expect(response).to redirect_to(new_password_reset_path)
      follow_redirect!
      expect(response.body).to include('link has expired')
    end
  end
end
