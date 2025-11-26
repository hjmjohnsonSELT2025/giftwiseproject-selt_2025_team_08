require 'rails_helper'

RSpec.describe 'Recipients API', type: :request do
  let(:user1) { create_user(email: 'user1@example.com', password: 'password123') }
  let(:user2) { create_user(email: 'user2@example.com', password: 'password123') }
  let(:event) { create(:event, creator: user1) }
  let(:recipient) { event.recipients.create!(first_name: 'John', last_name: 'Doe') }

  before do
    post session_path, params: { email: user1.email, password: 'password123' }
  end

  describe 'POST /events/:event_id/recipients (create)' do
    it 'creates a new recipient for an event' do
      expect {
        post event_recipients_path(event), params: {
          recipient: {
            first_name: 'Jane',
            last_name: 'Smith',
            age: 28,
            occupation: 'Doctor'
          }
        }
      }.to change(Recipient, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'returns JSON with recipient details' do
      post event_recipients_path(event), params: {
        recipient: { first_name: 'Jane', last_name: 'Smith' }
      }

      json_response = JSON.parse(response.body)
      expect(json_response['first_name']).to eq('Jane')
      expect(json_response['last_name']).to eq('Smith')
    end

    it 'requires first_name and last_name' do
      post event_recipients_path(event), params: {
        recipient: { age: 25 }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'DELETE /recipients/:id (destroy)' do
    it 'deletes a recipient and cascades to gift ideas' do
      gift_idea = recipient.gift_ideas.create!(idea: 'A book', user: user1)
      
      expect {
        delete recipient_path(recipient)
      }.to change(Recipient, :count).by(-1)
        .and change(GiftIdea, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it 'deletes a recipient and cascades to gifts for recipients' do
      gift = recipient.gifts_for_recipients.create!(idea: 'A watch', user: user1)
      
      expect {
        delete recipient_path(recipient)
      }.to change(Recipient, :count).by(-1)
        .and change(GiftForRecipient, :count).by(-1)
    end
  end

  describe 'GET /recipients/:id/data.json (data endpoint)' do
    it 'returns user-specific previous gifts and favorited ideas' do
      recipient.gifts_for_recipients.create!(idea: 'Book', price: 20, user: user1)
      recipient.gift_ideas.create!(idea: 'Watch', user: user1, favorited: true)
      recipient.gifts_for_recipients.create!(idea: 'Shoes', user: user2)
      recipient.gift_ideas.create!(idea: 'Jacket', user: user2, favorited: true)

      get "/recipients/#{recipient.id}/data.json"

      json_response = JSON.parse(response.body)
      expect(json_response['previous_gifts'].length).to eq(1)
      expect(json_response['previous_gifts'].first['idea']).to eq('Book')
      expect(json_response['favorited_ideas'].length).to eq(1)
      expect(json_response['favorited_ideas'].first['idea']).to eq('Watch')
    end

    it 'returns only the current users gifts and ideas' do
      recipient.gifts_for_recipients.create!(idea: 'Book', user: user1)
      recipient.gift_ideas.create!(idea: 'Watch', user: user1, favorited: true)

      delete session_path
      post session_path, params: { email: user2.email, password: 'password123' }

      get "/recipients/#{recipient.id}/data.json"

      json_response = JSON.parse(response.body)
      expect(json_response['previous_gifts'].length).to eq(0)
      expect(json_response['favorited_ideas'].length).to eq(0)
    end

    it 'returns only favorited ideas' do
      recipient.gift_ideas.create!(idea: 'Favorited watch', user: user1, favorited: true)
      recipient.gift_ideas.create!(idea: 'Unfavorited book', user: user1, favorited: false)

      get "/recipients/#{recipient.id}/data.json"

      json_response = JSON.parse(response.body)
      expect(json_response['favorited_ideas'].length).to eq(1)
      expect(json_response['favorited_ideas'].first['idea']).to eq('Favorited watch')
    end
  end

  describe 'POST /recipients/:id/gift_ideas (create gift idea)' do
    it 'creates a gift idea for a recipient' do
      expect {
        post "/recipients/#{recipient.id}/gift_ideas", params: {
          gift_idea: {
            idea: 'Wireless headphones',
            estimated_price: 150,
            favorited: true
          }
        }
      }.to change(GiftIdea, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'associates the gift idea with the current user' do
      post "/recipients/#{recipient.id}/gift_ideas", params: {
        gift_idea: { idea: 'A book', favorited: true }
      }

      gift_idea = GiftIdea.last
      expect(gift_idea.user).to eq(user1)
    end

    it 'returns JSON with gift idea details' do
      post "/recipients/#{recipient.id}/gift_ideas", params: {
        gift_idea: { idea: 'A watch', estimated_price: 200, favorited: true }
      }

      json_response = JSON.parse(response.body)
      expect(json_response['idea']).to eq('A watch')
      expect(json_response['estimated_price'].to_f).to eq(200.0)
      expect(json_response['favorited']).to be_truthy
    end
  end

  describe 'POST /recipients/:id/gifts_for_recipients (record gift)' do
    it 'records a gift given to a recipient' do
      expect {
        post "/recipients/#{recipient.id}/gifts_for_recipients", params: {
          gift_for_recipient: {
            idea: 'A watch',
            price: 150,
            gift_date: Date.today
          }
        }
      }.to change(GiftForRecipient, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'associates the gift with the current user' do
      post "/recipients/#{recipient.id}/gifts_for_recipients", params: {
        gift_for_recipient: { idea: 'A book', price: 20 }
      }

      gift = GiftForRecipient.last
      expect(gift.user).to eq(user1)
    end

    it 'returns JSON with gift details' do
      post "/recipients/#{recipient.id}/gifts_for_recipients", params: {
        gift_for_recipient: { idea: 'A watch', price: 150, gift_date: '2025-11-25' }
      }

      json_response = JSON.parse(response.body)
      expect(json_response['idea']).to eq('A watch')
      expect(json_response['price'].to_f).to eq(150.0)
    end
  end

  describe 'POST /recipients/:id/generate_ideas.json (generate ideas)' do
    it 'generates gift ideas using Gemini API' do
      allow_any_instance_of(GeminiService).to receive(:generate_multiple_ideas).and_return(
        "1. A nice book about technology\n2. Wireless headphones\n3. A smartwatch"
      )

      post "/recipients/#{recipient.id}/generate_ideas.json", params: {
        price_min: 50,
        price_max: 300,
        num_ideas: 3
      }

      json_response = JSON.parse(response.body)
      expect(json_response['ideas']).to be_an(Array)
      expect(json_response['ideas'].length).to eq(3)
      expect(json_response['ideas'].first).to include('book', 'technology')
    end

    it 'includes price range and recipient info in the prompt' do
      expect_any_instance_of(GeminiService).to receive(:generate_multiple_ideas).with(
        include(recipient.first_name, recipient.last_name, '50', '300'),
        3
      ).and_return("1. Gift idea 1\n2. Gift idea 2\n3. Gift idea 3")

      post "/recipients/#{recipient.id}/generate_ideas.json", params: {
        price_min: 50,
        price_max: 300,
        num_ideas: 3
      }
    end
  end
end
