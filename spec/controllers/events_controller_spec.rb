require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) { create_user(email: 'user@example.com', password: 'password123') }

  describe 'authentication' do
    it 'requires login for index action' do
      get :index
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for new action' do
      get :new
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'with authenticated user' do
    before do
      sign_in user
    end

    describe 'GET #index' do
      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a successful response' do
        get :new
        expect(response).to be_successful
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  private

  def sign_in(user)
    session[:user_id] = user.id
  end
end
