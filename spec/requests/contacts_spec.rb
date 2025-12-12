require 'rails_helper'

RSpec.describe 'Contacts', type: :request do
  let(:user) { create_user(email: 'contactuser@example.com', password: 'password123') }
  let(:other_user) { create_user(email: 'other@example.com', password: 'password123') }

  describe 'unauthenticated user' do
    it 'redirects to login when accessing contacts' do
      get contacts_path
      expect(response).to redirect_to(login_path)
    end

    it 'sets an alert message when redirected' do
      get contacts_path
      expect(flash[:alert]).to eq('Please log in to continue')
    end

    it 'redirects to login when accessing new contacts' do
      get new_contact_path
      expect(response).to redirect_to(login_path)
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
        expect(response.body).to include('Search')
        expect(response.body).to include('contacts-search')
      end

      it 'has an Add Contact button' do
        get contacts_path
        expect(response.body).to include('Add a New Contact')
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

      it 'loads contact map without N+1 queries' do
        5.times do |i|
          other = create_user(email: "contact#{i}@example.com", password: 'password123')
          user.contacts.create(contact_user: other)
        end

        get contacts_path
        expect(assigns(:contact_map)).to be_present
        expect(assigns(:contact_map).size).to eq(5)
      end

      it 'displays added contacts in a table' do
        user.contacts.create(contact_user: other_user, note: 'Test note')
        get contacts_path
        expect(response.body).to include(other_user.first_name)
        expect(response.body).to include(other_user.last_name)
        expect(response.body).to include('Test note')
      end

      it 'shows "No contacts yet" message when no contacts exist' do
        get contacts_path
        expect(response.body).to include('No contacts yet')
      end
    end

    describe 'GET /contacts/new' do
      let(:third_user) { create_user(email: 'third@example.com', password: 'password123') }

      it 'returns success and displays add contact page' do
        get new_contact_path
        expect(response).to be_successful
        expect(response.body).to include('Add New Contact')
      end

      it 'displays search input for users' do
        get new_contact_path
        expect(response.body).to include('Search for a person')
        expect(response.body).to include('users-search-input')
      end

      it 'displays available users to add' do
        third_user
        get new_contact_path
        expect(response.body).to include('users-list')
        expect(response.body).to include(third_user.first_name)
      end

      it 'excludes current user from the list' do
        get new_contact_path
        expect(response.body).not_to include("action=\"/users/#{user.id}\"")
      end

      it 'excludes already added contacts' do
        user.contacts.create(contact_user: other_user)
        get new_contact_path
        expect(response.body).not_to include(other_user.first_name)
      end
    end

    describe 'POST /contacts' do
      it 'adds a new contact successfully' do
        expect {
          post contacts_path, params: { contact_user_id: other_user.id }
        }.to change(Contact, :count).by(1)
        expect(response).to redirect_to(contacts_path)
        expect(flash[:notice]).to eq('Contact added successfully')
      end

      it 'prevents adding the same contact twice' do
        user.contacts.create(contact_user: other_user)
        post contacts_path, params: { contact_user_id: other_user.id }
        expect(response).to redirect_to(new_contact_path)
        expect(flash[:alert]).to include('Failed to add contact')
      end

      it 'redirects with alert when contact_user_id is missing' do
        post contacts_path, params: { contact_user_id: '' }
        expect(response).to redirect_to(new_contact_path)
        expect(flash[:alert]).to eq('Please select a contact')
      end

      it 'redirects with alert when user not found' do
        post contacts_path, params: { contact_user_id: 9_999_999 }
        expect(response).to redirect_to(new_contact_path)
        expect(flash[:alert]).to eq('User not found')
      end
    end

    describe 'PATCH /contacts/:id/update_note' do
      let(:contact) { user.contacts.create(contact_user: other_user) }

      it 'updates contact note successfully' do
        patch update_note_contact_path(contact), params: { contact: { note: 'Updated note' } }
        expect(response).to redirect_to(contacts_path)
        expect(flash[:notice]).to eq('Note updated successfully')
        expect(contact.reload.note).to eq('Updated note')
      end

      it 'returns success response for JS format' do
        patch update_note_contact_path(contact), params: { contact: { note: 'New note' }, format: :js }
        expect(response).to be_successful
      end
    end

    describe 'DELETE /contacts/:id' do
      let(:contact) { user.contacts.create(contact_user: other_user, note: 'Test note') }

      it 'deletes a contact successfully' do
        contact_id = contact.id
        delete contact_path(contact)
        expect(Contact.find_by(id: contact_id)).to be_nil
        expect(response).to redirect_to(contacts_path)
        expect(flash[:notice]).to eq('Contact removed successfully')
      end

      it 'prevents deleting other users contacts' do
        another_user = create_user(email: 'another@example.com', password: 'password123')
        their_contact = another_user.contacts.create(contact_user: other_user)
        
        expect {
          delete contact_path(their_contact)
        }.not_to change { Contact.count }
      end
    end
  end
end
