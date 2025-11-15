require 'rails_helper'

RSpec.describe 'Contacts', type: :request do
  let(:user) { create_user(email: 'contactuser@example.com', password: 'password123') }

  describe 'unauthenticated user' do
    it 'redirects to login when accessing contacts' do
      get contacts_path
      expect(response).to redirect_to(login_path)
    end

    it 'sets an alert message when redirected' do
      get contacts_path
      expect(flash[:alert]).to eq('Please log in to continue')
    end
  end

  describe 'authenticated user' do
    before do
      post session_path, params: { email: user.email, password: 'password123' }
    end

    describe 'GET /contacts' do
      it 'returns success and displays the page heading' do
        get contacts_path
        expect(response).to be_successful
        expect(response.body).to include('Contacts')
      end

      it 'renders the search input for contacts' do
        get contacts_path
        expect(response.body).to include('Search Contacts')
        expect(response.body).to include('contacts-search')
      end

      it 'has an Add Contact button' do
        get contacts_path
        expect(response.body).to include('Add Contact')
        expect(response.body).to include(new_contact_path)
      end

      it 'shows top navigation links including logout' do
        get contacts_path
        expect(response.body).to include(root_path)
        expect(response.body).to include(contacts_path)
        expect(response.body).to include(events_path)
        expect(response.body).to include(settings_path)
        expect(response.body).to include('Logout')
      end
    end
  end
end
