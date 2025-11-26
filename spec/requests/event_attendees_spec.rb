require 'rails_helper'

RSpec.describe 'Event Attendees', type: :request do
  let(:user1) { create_user(email: 'user1@example.com', password: 'password123') }
  let(:user2) { create_user(email: 'user2@example.com', password: 'password123') }
  let(:user3) { create_user(email: 'user3@example.com', password: 'password123') }
  let(:event) { create(:event, creator: user1) }

  before do
    post session_path, params: { email: user1.email, password: 'password123' }
  end

  describe 'POST /events/:event_id/attendees (add attendee)' do
    it 'adds an attendee to an event' do
      expect {
        post "/events/#{event.id}/attendees", params: {
          event_attendee: {
            user_id: user2.id
          }
        }
      }.to change(EventAttendee, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'prevents adding the same attendee twice' do
      event.event_attendees.create!(user: user2)
      
      post "/events/#{event.id}/attendees", params: { event_attendee: { user_id: user2.id } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'only allows the event creator to add attendees' do
      delete session_path
      post session_path, params: { email: user2.email, password: 'password123' }

      post "/events/#{event.id}/attendees", params: { event_attendee: { user_id: user3.id } }
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns attendee JSON on success' do
      post "/events/#{event.id}/attendees", params: { event_attendee: { user_id: user2.id } }

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['user_id']).to eq(user2.id)
    end
  end

  describe 'DELETE /events/:event_id/attendees/:id (remove attendee)' do
    it 'removes an attendee from an event' do
      attendee = event.event_attendees.create!(user: user2)

      expect {
        delete "/events/#{event.id}/attendees/#{attendee.id}"
      }.to change(EventAttendee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'only allows the event creator to remove attendees' do
      attendee = event.event_attendees.create!(user: user2)
      
      delete session_path
      post session_path, params: { email: user2.email, password: 'password123' }

      delete "/events/#{event.id}/attendees/#{attendee.id}"
      expect(response).to have_http_status(:forbidden)
    end

    it 'does not remove attendees from other events' do
      event2 = create(:event, creator: user1)
      attendee1 = event.event_attendees.create!(user: user2)
      attendee2 = event2.event_attendees.create!(user: user2)

      delete session_path
      post session_path, params: { email: user1.email, password: 'password123' }

      delete "/events/#{event.id}/attendees/#{attendee1.id}"

      expect(event.event_attendees.exists?).to be_falsey
      expect(event2.event_attendees.exists?).to be_truthy
    end
  end

  describe 'Event attendee associations' do
    it 'adds the creator as an attendee when event is created' do
      post events_path, params: {
        event: {
          name: 'Test Event',
          start_at: '2025-12-01T10:00',
          end_at: '2025-12-01T11:00'
        }
      }

      new_event = Event.last
      expect(new_event.event_attendees.where(user: user1)).to exist
    end

    it 'retrieves all attendees for an event' do
      event.event_attendees.create!(user: user2)
      event.event_attendees.create!(user: user3)

      attendees = event.attendees
      expect(attendees.count).to eq(2)
      expect(attendees).to include(user2, user3)
    end
  end
end
