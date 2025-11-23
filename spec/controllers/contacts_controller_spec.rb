require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:user) { create_user(email: 'controller@example.com') }
  let(:other_user) { create_user(email: 'other-controller@example.com') }

  describe 'GET #index' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(login_path)
      end

      it 'sets an alert message' do
        get :index
        expect(flash[:alert]).to eq('Please log in to continue')
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns contacts to @contacts' do
        user.contacts.create(contact_user: other_user)
        get :index
        expect(assigns(:contacts)).to eq([other_user])
      end

      it 'returns empty contacts array when user has no contacts' do
        get :index
        expect(assigns(:contacts)).to be_empty
      end
    end
  end

  describe 'GET #new' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :new
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'returns a successful response' do
        get :new
        expect(response).to be_successful
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'assigns available users to @users' do
        get :new
        expect(assigns(:users)).to include(other_user)
      end

      it 'excludes current user from @users' do
        get :new
        expect(assigns(:users)).not_to include(user)
      end

      it 'excludes already added contacts from @users' do
        user.contacts.create(contact_user: other_user)
        get :new
        expect(assigns(:users)).not_to include(other_user)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        post :create, params: { contact_user_id: other_user.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'creates a new contact' do
        expect {
          post :create, params: { contact_user_id: other_user.id }
        }.to change(Contact, :count).by(1)
      end

      it 'redirects to contacts path on success' do
        post :create, params: { contact_user_id: other_user.id }
        expect(response).to redirect_to(contacts_path)
      end

      it 'sets success notice on creation' do
        post :create, params: { contact_user_id: other_user.id }
        expect(flash[:notice]).to eq('Contact added successfully')
      end

      it 'redirects with alert when contact_user_id is blank' do
        post :create, params: { contact_user_id: '' }
        expect(response).to redirect_to(new_contact_path)
        expect(flash[:alert]).to eq('Please select a contact')
      end

      it 'redirects with alert when user not found' do
        post :create, params: { contact_user_id: 9_999_999 }
        expect(response).to redirect_to(new_contact_path)
        expect(flash[:alert]).to eq('User not found')
      end

      it 'prevents duplicate contacts' do
        user.contacts.create(contact_user: other_user)
        post :create, params: { contact_user_id: other_user.id }
        expect(flash[:alert]).to include('Failed to add contact')
        expect(Contact.where(user_id: user.id, contact_user_id: other_user.id).count).to eq(1)
      end
    end
  end

  describe 'GET #edit_note' do
    let(:contact) { user.contacts.create(contact_user: other_user, note: 'Test note') }

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :edit_note, params: { id: contact.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'returns a successful response' do
        get :edit_note, params: { id: contact.id }
        expect(response).to be_successful
      end

      it 'renders without layout' do
        get :edit_note, params: { id: contact.id }
        expect(response).to render_template(:edit_note)
      end

      it 'assigns the contact to @contact' do
        get :edit_note, params: { id: contact.id }
        expect(assigns(:contact)).to eq(contact)
      end
    end
  end

  describe 'PATCH #update_note' do
    let(:contact) { user.contacts.create(contact_user: other_user, note: 'Original note') }

    context 'when user is not logged in' do
      it 'redirects to login page' do
        patch :update_note, params: { id: contact.id, contact: { note: 'Updated' } }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'updates the contact note' do
        patch :update_note, params: { id: contact.id, contact: { note: 'Updated note' } }
        expect(contact.reload.note).to eq('Updated note')
      end

      it 'redirects to contacts path' do
        patch :update_note, params: { id: contact.id, contact: { note: 'Updated' } }
        expect(response).to redirect_to(contacts_path)
      end

      it 'sets success notice' do
        patch :update_note, params: { id: contact.id, contact: { note: 'Updated' } }
        expect(flash[:notice]).to eq('Note updated successfully')
      end

      it 'handles blank notes' do
        patch :update_note, params: { id: contact.id, contact: { note: '' } }
        expect(contact.reload.note).to eq('')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:contact) { user.contacts.create(contact_user: other_user, note: 'Test note') }

    context 'when user is not logged in' do
      it 'redirects to login page' do
        delete :destroy, params: { id: contact.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'deletes the contact' do
        contact_id = contact.id
        delete :destroy, params: { id: contact_id }
        expect(Contact.find_by(id: contact_id)).to be_nil
      end

      it 'redirects to contacts path' do
        delete :destroy, params: { id: contact.id }
        expect(response).to redirect_to(contacts_path)
      end

      it 'sets success notice' do
        delete :destroy, params: { id: contact.id }
        expect(flash[:notice]).to eq('Contact removed successfully')
      end

      it 'prevents deleting other users contacts' do
        another_user = create_user(email: 'another-controller@example.com')
        their_contact = another_user.contacts.create(contact_user: other_user)
        
        expect {
          delete :destroy, params: { id: their_contact.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'require_login filter' do
    let(:user) { create_user(email: 'contacts-filter@example.com') }

    it 'blocks unauthenticated access' do
      get :index
      expect(response).to redirect_to(login_path)
    end

    it 'allows authenticated access' do
      session[:user_id] = user.id
      get :index
      expect(response).to be_successful
    end

    it 'redirects to login for invalid session' do
      session[:user_id] = 9_999_999
      get :index
      expect(response).to redirect_to(login_path)
    end
  end
end
