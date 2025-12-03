require 'rails_helper'

RSpec.describe GiftIdeasController, type: :controller do
  let(:user) { create_user(email: 'user@example.com', password: 'password123') }
  let(:event) { create(:event, creator: user) }
  let(:recipient) { event.recipients.create!(first_name: 'John', last_name: 'Doe') }
  let(:gift_idea) do
    recipient.gift_ideas.create!(
      idea: 'Test gift idea',
      estimated_price: 50.00,
      user: user,
      link: 'https://example.com/product',
      note: 'Great product',
      favorited: true
    )
  end

  before do
    sign_in user
  end

  describe 'GET #show' do
    context 'with valid gift idea' do
      it 'returns the gift idea as JSON' do
        get :show, params: { id: gift_idea.id }, format: :json
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        
        expect(json_response['id']).to eq(gift_idea.id)
        expect(json_response['idea']).to eq('Test gift idea')
        expect(json_response['estimated_price']).to eq('50.0')
        expect(json_response['link']).to eq('https://example.com/product')
        expect(json_response['note']).to eq('Great product')
        expect(json_response['favorited']).to be true
      end

      it 'includes link and note in response' do
        get :show, params: { id: gift_idea.id }, format: :json
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('link')
        expect(json_response).to have_key('note')
      end

      it 'handles gift ideas without link and note' do
        gift_idea.update(link: nil, note: nil)
        
        get :show, params: { id: gift_idea.id }, format: :json
        
        json_response = JSON.parse(response.body)
        expect(json_response['link']).to be_nil
        expect(json_response['note']).to be_nil
      end
    end

    context 'with non-existent gift idea' do
      it 'returns 404 not found' do
        get :show, params: { id: 99999 }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not authenticated' do
      before { sign_out }

      it 'redirects to login' do
        get :show, params: { id: gift_idea.id }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: gift_idea.id,
          gift_idea: {
            idea: 'Updated idea',
            estimated_price: 100.00,
            link: 'https://newlink.com/product',
            note: 'Updated note',
            favorited: false
          }
        }
      end

      it 'updates the gift idea' do
        patch :update, params: valid_params, format: :json
        
        expect(response).to have_http_status(:success)
        gift_idea.reload
        
        expect(gift_idea.idea).to eq('Updated idea')
        expect(gift_idea.estimated_price).to eq(100.00)
        expect(gift_idea.link).to eq('https://newlink.com/product')
        expect(gift_idea.note).to eq('Updated note')
        expect(gift_idea.favorited).to be false
      end

      it 'returns updated gift idea with all fields' do
        patch :update, params: valid_params, format: :json
        
        json_response = JSON.parse(response.body)
        expect(json_response['idea']).to eq('Updated idea')
        expect(json_response['estimated_price']).to eq('100.0')
        expect(json_response['link']).to eq('https://newlink.com/product')
        expect(json_response['note']).to eq('Updated note')
        expect(json_response['favorited']).to be false
      end
    end

    context 'updating only specific fields' do
      it 'updates only the price' do
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { estimated_price: 75.00 }
        }, format: :json
        
        gift_idea.reload
        expect(gift_idea.estimated_price).to eq(75.00)
        expect(gift_idea.idea).to eq('Test gift idea')
        expect(gift_idea.link).to eq('https://example.com/product')
      end

      it 'updates only the link' do
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { link: 'https://different.com' }
        }, format: :json
        
        gift_idea.reload
        expect(gift_idea.link).to eq('https://different.com')
      end

      it 'updates only the note' do
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { note: 'New note' }
        }, format: :json
        
        gift_idea.reload
        expect(gift_idea.note).to eq('New note')
      end

      it 'clears the link' do
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { link: '' }
        }, format: :json
        
        gift_idea.reload
        expect(gift_idea.link).to be_blank
      end

      it 'clears the note' do
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { note: '' }
        }, format: :json
        
        gift_idea.reload
        expect(gift_idea.note).to be_blank
      end
    end

    context 'with invalid parameters' do
      it 'rejects update with invalid URL' do
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { link: 'not a valid url' }
        }, format: :json
        
        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('link')
      end

      it 'rejects update with note exceeding 255 characters' do
        long_note = 'a' * 256
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { note: long_note }
        }, format: :json
        
        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('note')
      end

      it 'rejects update with empty idea' do
        patch :update, params: {
          id: gift_idea.id,
          gift_idea: { idea: '' }
        }, format: :json
        
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when not authenticated' do
      before { sign_out }

      it 'redirects to login' do
        patch :update, params: { id: gift_idea.id, gift_idea: { idea: 'Test' } }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'permitted parameters' do
    it 'permits link and note fields' do
      params = ActionController::Parameters.new({
        gift_idea: {
          idea: 'Test',
          estimated_price: 50,
          link: 'https://example.com',
          note: 'Test note',
          favorited: true
        }
      })
      
      permitted = params.require(:gift_idea).permit(:idea, :estimated_price, :link, :note, :favorited)
      expect(permitted['idea']).to eq('Test')
      expect(permitted['estimated_price']).to eq(50)
      expect(permitted['link']).to eq('https://example.com')
      expect(permitted['note']).to eq('Test note')
      expect(permitted['favorited']).to be true
    end
  end

  private

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = nil
  end
end
