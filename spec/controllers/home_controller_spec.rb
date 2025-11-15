require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(login_path)
      end

      it 'sets an alert message' do
        get :index
        expect(flash[:alert]).to eq("Please log in to continue")
      end
    end

    context 'when user is logged in' do
      let(:user) { create_user(email: 'test@example.com') }

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

      it 'sets the user in session' do
        get :index
        expect(session[:user_id]).to eq(user.id)
      end

      it 'has access to current_user helper' do
        get :index
        expect(assigns(:current_user)).to eq(user)
      end
    end
  end

  describe 'require_login filter' do
    let(:user) { create_user(email: 'filter@example.com') }

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
      session[:user_id] = 99999
      get :index
      expect(response).to redirect_to(login_path)
    end
  end
end
