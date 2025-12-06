require 'rails_helper'

RSpec.describe WishListItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:wish_list_item) { create(:wish_list_item, user: user) }

  before { session[:user_id] = user.id }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns wish_list_items' do
      create_list(:wish_list_item, 3, user: user)
      get :index
      expect(assigns(:wish_list_items)).to match_array(user.wish_list_items)
    end

    it 'orders items by creation date descending' do
      item1 = create(:wish_list_item, user: user, name: 'Item 1')
      item2 = create(:wish_list_item, user: user, name: 'Item 2')
      
      get :index
      expect(assigns(:wish_list_items)).to eq([item2, item1])
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new wish_list_item' do
      get :new
      expect(assigns(:wish_list_item)).to be_a_new(WishListItem)
      expect(assigns(:wish_list_item).user).to eq(user)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          wish_list_item: {
            name: 'New Laptop',
            description: 'A powerful laptop',
            url: 'https://example.com/laptop',
            price: '1299.99'
          }
        }
      end

      it 'creates a new wish_list_item' do
        expect {
          post :create, params: valid_params
        }.to change(WishListItem, :count).by(1)
      end

      it 'redirects to index' do
        post :create, params: valid_params
        expect(response).to redirect_to(wish_list_items_path)
      end

      it 'displays success message' do
        post :create, params: valid_params
        expect(flash[:notice]).to include('successfully created')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          wish_list_item: {
            name: ''
          }
        }
      end

      it 'does not create a new wish_list_item' do
        expect {
          post :create, params: invalid_params
        }.not_to change(WishListItem, :count)
      end

      it 're-renders the new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end

    context 'when user has 10 items' do
      before do
        10.times do |i|
          create(:wish_list_item, user: user, name: "Item #{i}")
        end
      end

      let(:valid_params) do
        {
          wish_list_item: {
            name: 'Item 11',
            price: '99.99'
          }
        }
      end

      it 'does not create a new item' do
        expect {
          post :create, params: valid_params
        }.not_to change(WishListItem, :count)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: wish_list_item.id }
      expect(response).to be_successful
    end

    it 'assigns the wish_list_item' do
      get :edit, params: { id: wish_list_item.id }
      expect(assigns(:wish_list_item)).to eq(wish_list_item)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_params) do
        {
          wish_list_item: {
            name: wish_list_item.name,
            description: 'Updated description',
            price: '199.99'
          }
        }
      end

      it 'updates the wish_list_item' do
        patch :update, params: { id: wish_list_item.id, **new_params }
        wish_list_item.reload
        expect(wish_list_item.description).to eq('Updated description')
        expect(wish_list_item.price).to eq(199.99)
      end

      it 'redirects to index' do
        patch :update, params: { id: wish_list_item.id, **new_params }
        expect(response).to redirect_to(wish_list_items_path)
      end

      it 'displays success message' do
        patch :update, params: { id: wish_list_item.id, **new_params }
        expect(flash[:notice]).to include('successfully updated')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          wish_list_item: {
            name: ''
          }
        }
      end

      it 'does not update the item' do
        patch :update, params: { id: wish_list_item.id, **invalid_params }
        wish_list_item.reload
        expect(wish_list_item.name).not_to be_empty
      end

      it 're-renders the edit template' do
        patch :update, params: { id: wish_list_item.id, **invalid_params }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the wish_list_item' do
      item = create(:wish_list_item, user: user)
      expect {
        delete :destroy, params: { id: item.id }
      }.to change(WishListItem, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, params: { id: wish_list_item.id }
      expect(response).to redirect_to(wish_list_items_path)
    end

    it 'displays success message' do
      delete :destroy, params: { id: wish_list_item.id }
      expect(flash[:notice]).to include('successfully destroyed')
    end
  end

  context 'authentication' do
    before { session.delete(:user_id) }

    it 'requires login for index' do
      get :index
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for create' do
      post :create, params: { wish_list_item: { name: 'Test' } }
      expect(response).to redirect_to(login_path)
    end
  end

  context 'authorization' do
    let(:other_user) { create(:user) }
    let(:other_item) { create(:wish_list_item, user: other_user) }

    it 'does not allow editing another user\'s item' do
      expect {
        patch :update, params: { id: other_item.id, wish_list_item: { name: 'Hacked' } }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not allow deleting another user\'s item' do
      expect {
        delete :destroy, params: { id: other_item.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
