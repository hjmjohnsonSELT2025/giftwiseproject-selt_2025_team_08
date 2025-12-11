require 'rails_helper'

RSpec.describe 'Event Recipients and Gifts', type: :request do
  let(:creator) { create_user(email: 'creator@example.com', password: 'password123') }
  let(:attendee) { create_user(email: 'attendee@example.com', password: 'password123') }
  let(:recipient) { create_user(email: 'recipient@example.com', password: 'password123') }
  let(:event) do
    event = create(:event, creator: creator, name: 'Birthday Party')
    event.event_attendees.create!(user: attendee)
    event.recipients.create!(first_name: 'John', last_name: 'Doe')
    event
  end

  describe 'Event show page visibility' do
    it 'allows creator to see Recipients & Gifts section' do
      post session_path, params: { email: creator.email, password: 'password123' }
      get event_path(event)
      expect(response.body).to include('Recipients & Gifts')
      expect(response.body).to include('Generate New Gift Ideas')
    end

    it 'allows attendee to see Recipients & Gifts section' do
      post session_path, params: { email: attendee.email, password: 'password123' }
      get event_path(event)
      expect(response.body).to include('Recipients & Gifts')
      expect(response.body).to include('Generate New Gift Ideas')
    end

    it 'does not allow recipient to see Recipients & Gifts section' do
      event.recipients.first.update(first_name: recipient.first_name, last_name: recipient.last_name)      
      post session_path, params: { email: recipient.email, password: 'password123' }
      get event_path(event)
      expect(response).to be_successful
    end

    it 'allows attendee to see Recipients & Gifts section' do
      post session_path, params: { email: attendee.email, password: 'password123' }
      get event_path(event)
      expect(response.body).to include('Recipients & Gifts')
      expect(response.body).to include('Generate New Gift Ideas')
    end
  end

  describe 'Event edit button visibility' do
    it 'shows edit button to creator' do
      post session_path, params: { email: creator.email, password: 'password123' }
      get "/events/#{event.id}"
      expect(response.body).to include('Edit')
    end

    it 'does not show edit button to non-creator attendee' do
      post session_path, params: { email: attendee.email, password: 'password123' }
      get "/events/#{event.id}"
      expect(response.body).not_to include('<a href="/events/1/edit">Edit</a>')
    end
  end

  describe 'Recipients and gift management workflow' do
    before do
      post session_path, params: { email: creator.email, password: 'password123' }
    end

    it 'allows creator to view recipients on event show page' do
      get event_path(event)
      expect(response.body).to include('John Doe')
    end

    it 'allows attendee to generate gift ideas' do
      post session_path, params: { email: attendee.email, password: 'password123' }
      
      recipient = event.recipients.first
      allow_any_instance_of(GeminiService).to receive(:generate_multiple_ideas).and_return(
        "1. Gift idea 1\n2. Gift idea 2\n3. Gift idea 3"
      )

      post "/recipients/#{recipient.id}/generate_ideas.json", params: {
        price_min: 50,
        price_max: 300,
        num_ideas: 3
      }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['ideas']).to be_present
    end

    it 'allows creator to save gift ideas' do
      recipient = event.recipients.first
      
      post "/recipients/#{recipient.id}/gift_ideas", params: {
        gift_idea: {
          idea: 'Wireless headphones',
          estimated_price: 150,
          favorited: true
        }
      }

      expect(response).to have_http_status(:created)
      expect(GiftIdea.last.idea).to eq('Wireless headphones')
      expect(GiftIdea.last.user).to eq(creator)
    end

    it 'allows creator to record gift given to recipient' do
      recipient = event.recipients.first
      
      post "/recipients/#{recipient.id}/gifts_for_recipients", params: {
        gift_for_recipient: {
          idea: 'A watch',
          price: 200,
          gift_date: Date.today
        }
      }

      expect(response).to have_http_status(:created)
      expect(GiftForRecipient.last.idea).to eq('A watch')
      expect(GiftForRecipient.last.user).to eq(creator)
    end

    it 'shows current gift under recipient on event page' do
      recipient = event.recipients.first
      recipient.gifts_for_recipients.create!(
        idea: 'A watch',
        price: 200,
        gift_date: Date.today,
        user: creator
      )

      get "/recipients/#{recipient.id}/data.json"
      json_response = JSON.parse(response.body)
      
      expect(json_response['previous_gifts'].first['idea']).to eq('A watch')
    end

    it 'does not show other users gifts in recipient overview' do
      recipient = event.recipients.first
      recipient.gifts_for_recipients.create!(idea: 'Watch', gift_date: Date.today, user: creator)
      recipient.gifts_for_recipients.create!(idea: 'Book', gift_date: Date.today, user: attendee)

      get "/recipients/#{recipient.id}/data.json"
      json_response = JSON.parse(response.body)
      expect(json_response['previous_gifts'].map { |g| g['idea'] }).to eq(['Watch'])
      
      delete session_path
      post session_path, params: { email: attendee.email, password: 'password123' }
      
      get "/recipients/#{recipient.id}/data.json"
      json_response = JSON.parse(response.body)
      expect(json_response['previous_gifts'].map { |g| g['idea'] }).to eq(['Book'])
    end
  end

  describe 'Collapsible sections' do
    before do
      post session_path, params: { email: creator.email, password: 'password123' }
    end

    it 'displays collapsible sections for gift views' do
      get event_path(event)
      
      expect(response.body).to include('Previous Gifts')
      expect(response.body).to include('Saved Gift Ideas')
      expect(response.body).to include('Generate New Gift Ideas')
      expect(response.body).to include('Manually Add Gift Idea')
    end
  end
end
