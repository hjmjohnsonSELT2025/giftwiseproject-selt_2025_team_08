require 'rails_helper'

RSpec.describe 'Home Page', type: :request do
  let(:user) { create_user(email: 'request@example.com', password: 'request123') }

  describe 'unauthenticated user' do
    it 'redirects to login when accessing home page' do
      get root_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'authenticated user' do
    before do
      post session_path, params: { email: user.email, password: 'request123' }
    end

    it 'displays the home page successfully' do
      get root_path
      expect(response).to be_successful
      expect(response.body).to include('Welcome to Gift Wise')
    end

    it 'shows the user greeting with first name' do
      get root_path
      expect(response.body).to include("Hello, #{user.first_name}!")
    end

    it 'displays the gift ideas section' do
      get root_path
      expect(response.body).to include('Your gift ideas')
      expect(response.body).to include('Coming soon...')
    end

    it 'renders the correct template' do
      get root_path
      expect(response).to render_template('home/index')
    end

    describe 'navigation links' do
      it 'includes home, events, settings links and logout button' do
        get root_path
        expect(response.body).to include(root_path)
        expect(response.body).to include(events_path)
        expect(response.body).to include('Logout')
      end
    end
  end

  describe 'multiple users' do
    let(:user_two) { create_user(email: 'another@example.com', password: 'another123', first_name: 'Jane') }

    it 'shows correct user first name for different users' do
      post session_path, params: { email: user.email, password: 'request123' }
      get root_path
      expect(response.body).to include("Hello, #{user.first_name}!")
      expect(response.body).not_to include("Hello, #{user_two.first_name}!")

      delete session_path

      post session_path, params: { email: user_two.email, password: 'another123' }
      get root_path
      expect(response.body).to include("Hello, #{user_two.first_name}!")
      expect(response.body).not_to include("Hello, #{user.first_name}!")
    end
  end
end
