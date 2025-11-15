require 'rails_helper'

RSpec.describe 'Events', type: :request do
  let(:user) { create_user(email: 'user@example.com', password: 'password123') }

  describe 'unauthenticated user' do
    it 'redirects to login when accessing events index' do
      get events_path
      expect(response).to redirect_to(login_path)
    end

    it 'redirects to login when accessing new event page' do
      get new_event_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'authenticated user' do
    before do
      post session_path, params: { email: user.email, password: 'password123' }
    end

    describe 'GET /events (index)' do
      it 'displays the events page successfully' do
        get events_path
        expect(response).to be_successful
        expect(response.body).to include('Events')
      end

      it 'displays the events toolbar with search form' do
        get events_path
        expect(response.body).to include('events-toolbar')
        expect(response.body).to include('Search Events')
      end

      it 'displays the search input field' do
        get events_path
        expect(response.body).to include('events-search')
        expect(response.body).to include('placeholder="Search Events"')
      end

      it 'displays the "Add Event" button' do
        get events_path
        expect(response.body).to include('Add Event')
        expect(response.body).to include('add-event')
      end

      it 'displays the events list container' do
        get events_path
        expect(response.body).to include('events-list')
      end

      it 'renders the correct template' do
        get events_path
        expect(response).to render_template('events/index')
      end
    end

    describe 'GET /events/new' do
      it 'displays the new event page successfully' do
        get new_event_path
        expect(response).to be_successful
        expect(response.body).to include('New Event')
      end

      it 'displays event creation form placeholder text' do
        get new_event_path
        expect(response.body).to include('Event creation form coming soon')
      end

      it 'displays a back link to events page' do
        get new_event_path
        expect(response.body).to include('Back to Events')
        expect(response.body).to include(events_path)
      end

      it 'renders the correct template' do
        get new_event_path
        expect(response).to render_template('events/new')
      end

      it 'displays event form container' do
        get new_event_path
        expect(response.body).to include('event-form-container')
      end

      it 'displays event form div' do
        get new_event_path
        expect(response.body).to include('event-form')
      end

      it 'displays event form actions div' do
        get new_event_path
        expect(response.body).to include('event-form-actions')
      end
    end

    describe 'navigation' do
      it 'can navigate from events index to new event page' do
        get events_path
        expect(response.body).to include(new_event_path)
      end

      it 'can navigate from new event page back to events index' do
        get new_event_path
        expect(response.body).to include(events_path)
      end
    end
  end

  describe 'Events controller actions' do
    let(:user) { create_user(email: 'test@example.com', password: 'password123') }

    before do
      post session_path, params: { email: user.email, password: 'password123' }
    end

    it 'events index action responds to GET requests' do
      expect {
        get events_path
      }.not_to raise_error
    end

    it 'new event action responds to GET requests' do
      expect {
        get new_event_path
      }.not_to raise_error
    end

    it 'events controller requires login for all actions' do
      delete session_path
      
      get events_path
      expect(response).to redirect_to(login_path)
      
      get new_event_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'multiple users' do
    let(:user1) { create_user(email: 'user1@example.com', password: 'password123') }
    let(:user2) { create_user(email: 'user2@example.com', password: 'password123') }

    it 'both users can access their own events page' do
      post session_path, params: { email: user1.email, password: 'password123' }
      expect(response).to redirect_to(root_path)
      
      get events_path
      expect(response).to be_successful
      
      delete session_path
      
      post session_path, params: { email: user2.email, password: 'password123' }
      get events_path
      expect(response).to be_successful
    end
  end
end
