require 'rails_helper'

RSpec.describe 'Home Page', type: :request do
  let(:user) { create_user(email: 'request@example.com', password: 'request123') }

  describe 'unauthenticated user' do
    it 'redirects to login when accessing home page' do
      get root_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'authenticated user' do
    before do
      post session_path, params: { email: user.email, password: 'request123' }
    end

    it 'displays the home page successfully' do
      get root_path
      expect(response).to be_successful
      expect(response.body).to include('Welcome back')
    end

    it 'shows the user greeting with first name' do
      get root_path
      expect(response.body).to include("Welcome back, #{user.first_name}!")
    end

    it 'displays the quick gift generator section' do
      get root_path
      expect(response.body).to include('Gift Idea Generator')
    end

    it 'renders the correct template' do
      get root_path
      expect(response).to render_template('home/index')
    end

    describe 'navigation links' do
      it 'includes home, events, settings links and logout button' do
        get root_path
        expect(response.body).to include(root_path)
        expect(response.body).to include(events_path)
        expect(response.body).to include('Logout')
      end
    end

    describe 'upcoming events this month' do
      it 'displays upcoming events section' do
        get root_path
        expect(response.body).to include('Upcoming Events')
      end

      it 'shows events where user is the creator' do
        event = create(:event, creator: user)

        get root_path
        expect(response.body).to include(event.name)
      end

      it 'shows events where user is an attendee' do
        creator = create(:user, email: 'creator@example.com')
        event = create(:event, creator: creator)
        create(:event_attendee, event: event, user: user)

        get root_path
        expect(response.body).to include(event.name)
      end

      it 'does not show events from other months' do
        start_time = Time.current - 2.months
        event = create(:event, creator: user, start_at: start_time, end_at: start_time + 2.hours)

        get root_path
        expect(response.body).not_to include(event.name)
      end

      it 'shows no events message when there are no upcoming events' do
        get root_path
        expect(response.body).to include('No upcoming events this month')
      end

      it 'displays event details correctly' do
        event = create(:event, 
          creator: user, 
          name: 'Birthday Party',
          location: 'Downtown Hall'
        )

        get root_path
        expect(response.body).to include('Birthday Party')
        expect(response.body).to include('Downtown Hall')
      end
    end
  end

  describe 'multiple users' do
    let(:user_two) { create_user(email: 'another@example.com', password: 'another123', first_name: 'Jane') }

    it 'shows correct user first name for different users' do
      post session_path, params: { email: user.email, password: 'request123' }
      get root_path
      expect(response.body).to include("Welcome back, #{user.first_name}!")
      expect(response.body).not_to include("Welcome back, #{user_two.first_name}!")

      delete session_path

      post session_path, params: { email: user_two.email, password: 'another123' }
      get root_path
      expect(response.body).to include("Welcome back, #{user_two.first_name}!")
      expect(response.body).not_to include("Hello, #{user.first_name}!")
    end

    it 'shows each user only their own events' do
      event_one = create(:event, creator: user)
      event_two = create(:event, creator: user_two)

      post session_path, params: { email: user.email, password: 'request123' }
      get root_path
      expect(response.body).to include(event_one.name)
      expect(response.body).not_to include(event_two.name)

      delete session_path

      post session_path, params: { email: user_two.email, password: 'another123' }
      get root_path
      expect(response.body).to include(event_two.name)
      expect(response.body).not_to include(event_one.name)
    end
  end
end
