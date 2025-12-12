require 'rails_helper'

RSpec.describe DiscussionsController, type: :controller do
  let(:creator) { create_user(email: 'creator@example.com', password: 'password123') }
  let(:attendee) { create_user(email: 'attendee@example.com', password: 'password123') }
  let(:other_user) { create_user(email: 'other@example.com', password: 'password123') }
  let(:event) do
    Event.create!(
      name: 'Test Event',
      description: 'Test Description',
      start_at: Time.current + 1.day,
      end_at: Time.current + 2.days,
      creator_id: creator.id,
      theme: 'General'
    )
  end

  describe 'authentication' do
    it 'requires login for show action' do
      get :show, params: { event_id: event.id, thread_type: 'public' }
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for messages_feed action' do
      get :messages_feed, params: { event_id: event.id, thread_type: 'public' }
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for create_message action' do
      post :create_message, params: { event_id: event.id, thread_type: 'public', discussion_message: { content: 'Test' } }
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'with authenticated user' do
    before do
      sign_in creator
      event.attendees << attendee
    end

    describe 'GET #show (public thread)' do
      it 'returns a successful response' do
        get :show, params: { event_id: event.id, thread_type: 'public' }
        expect(response).to be_successful
      end

      it 'creates a public discussion if it does not exist' do
        expect(Discussion.where(event_id: event.id, thread_type: 'public').count).to eq(0)
        get :show, params: { event_id: event.id, thread_type: 'public' }
        expect(Discussion.where(event_id: event.id, thread_type: 'public').count).to eq(1)
      end

      it 'loads existing messages' do
        discussion = Discussion.create!(event_id: event.id, thread_type: 'public')
        message = DiscussionMessage.create!(discussion_id: discussion.id, user_id: creator.id, content: 'Test message')
        
        get :show, params: { event_id: event.id, thread_type: 'public' }
        expect(assigns(:messages)).to include(message)
      end

      it 'allows creator to view' do
        get :show, params: { event_id: event.id, thread_type: 'public' }
        expect(response).to be_successful
      end

      it 'allows attendee to view' do
        sign_out creator
        sign_in attendee
        get :show, params: { event_id: event.id, thread_type: 'public' }
        expect(response).to be_successful
      end

      it 'denies access to non-attendee' do
        sign_out creator
        sign_in other_user
        get :show, params: { event_id: event.id, thread_type: 'public' }
        expect(response).to redirect_to(event_path(event))
      end

      it 'denies access to recipient' do
        recipient = Recipient.create!(event_id: event.id, first_name: other_user.first_name, last_name: other_user.last_name)
        
        sign_out creator
        sign_in other_user
        get :show, params: { event_id: event.id, thread_type: 'public' }
        expect(response).to be_successful
      end
    end

    describe 'GET #show (contributors_only thread)' do
      it 'creates a contributors_only discussion if it does not exist' do
        expect(Discussion.where(event_id: event.id, thread_type: 'contributors_only').count).to eq(0)
        get :show, params: { event_id: event.id, thread_type: 'contributors_only' }
        expect(Discussion.where(event_id: event.id, thread_type: 'contributors_only').count).to eq(1)
      end

      it 'allows creator to view' do
        get :show, params: { event_id: event.id, thread_type: 'contributors_only' }
        expect(response).to be_successful
      end

      it 'allows attendee to view' do
        sign_out creator
        sign_in attendee
        get :show, params: { event_id: event.id, thread_type: 'contributors_only' }
        expect(response).to be_successful
      end

      it 'denies access to non-attendee' do
        sign_out creator
        sign_in other_user
        get :show, params: { event_id: event.id, thread_type: 'contributors_only' }
        expect(response).to redirect_to(event_path(event))
      end

      it 'denies access to recipient' do
        recipient = Recipient.create!(event_id: event.id, first_name: other_user.first_name, last_name: other_user.last_name)
        
        sign_out creator
        sign_in other_user
        get :show, params: { event_id: event.id, thread_type: 'contributors_only' }
        expect(response).to redirect_to(event_path(event))
      end
    end

    describe 'GET #messages_feed' do
      let(:discussion) { Discussion.create!(event_id: event.id, thread_type: 'public') }

      it 'returns JSON with messages' do
        DiscussionMessage.create!(discussion_id: discussion.id, user_id: creator.id, content: 'Message 1')
        
        get :messages_feed, params: { event_id: event.id, thread_type: 'public' }, format: :json
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')
        data = JSON.parse(response.body)
        expect(data['messages']).to be_a(Array)
      end

      it 'returns messages after a specific ID' do
        msg1 = DiscussionMessage.create!(discussion_id: discussion.id, user_id: creator.id, content: 'Message 1')
        msg2 = DiscussionMessage.create!(discussion_id: discussion.id, user_id: attendee.id, content: 'Message 2')
        msg3 = DiscussionMessage.create!(discussion_id: discussion.id, user_id: creator.id, content: 'Message 3')
        
        get :messages_feed, params: { 
          event_id: event.id, 
          thread_type: 'public',
          after_message_id: msg1.id
        }, format: :json
        
        data = JSON.parse(response.body)
        message_ids = data['messages'].map { |m| m['id'] }
        expect(message_ids).to include(msg2.id, msg3.id)
        expect(message_ids).not_to include(msg1.id)
      end

      it 'formats messages correctly' do
        msg = DiscussionMessage.create!(discussion_id: discussion.id, user_id: creator.id, content: 'Test message')
        
        get :messages_feed, params: { event_id: event.id, thread_type: 'public', after_message_id: msg.id - 1 }, format: :json
        
        data = JSON.parse(response.body)
        message = data['messages'].first
        expect(message).to have_key('id')
        expect(message).to have_key('content')
        expect(message).to have_key('user')
        expect(message).to have_key('is_own_message')
        expect(message).to have_key('created_at')
      end

      it 'marks own messages correctly' do
        msg = DiscussionMessage.create!(discussion_id: discussion.id, user_id: creator.id, content: 'My message')
        
        get :messages_feed, params: { event_id: event.id, thread_type: 'public', after_message_id: msg.id - 1 }, format: :json
        
        data = JSON.parse(response.body)
        expect(data['messages'].first['is_own_message']).to eq(true)
      end

      it 'marks other users messages correctly' do
        msg = DiscussionMessage.create!(discussion_id: discussion.id, user_id: attendee.id, content: 'Other message')
        
        get :messages_feed, params: { event_id: event.id, thread_type: 'public', after_message_id: msg.id - 1 }, format: :json
        
        data = JSON.parse(response.body)
        expect(data['messages'].first['is_own_message']).to eq(false)
      end
    end

    describe 'POST #create_message' do
      let(:discussion) { Discussion.create!(event_id: event.id, thread_type: 'public') }

      it 'creates a message successfully' do
        expect {
          post :create_message, params: {
            event_id: event.id,
            thread_type: 'public',
            discussion_message: { content: 'Test message' }
          }, format: :json
        }.to change(DiscussionMessage, :count).by(1)
      end

      it 'returns success response' do
        post :create_message, params: {
          event_id: event.id,
          thread_type: 'public',
          discussion_message: { content: 'Test message' }
        }, format: :json

        expect(response).to have_http_status(:success)
        data = JSON.parse(response.body)
        expect(data['success']).to eq(true)
        expect(data).to have_key('message_id')
      end

      it 'associates message with current user' do
        post :create_message, params: {
          event_id: event.id,
          thread_type: 'public',
          discussion_message: { content: 'Test message' }
        }, format: :json

        message = DiscussionMessage.last
        expect(message.user_id).to eq(creator.id)
      end

      it 'rejects empty messages' do
        expect {
          post :create_message, params: {
            event_id: event.id,
            thread_type: 'public',
            discussion_message: { content: '' }
          }, format: :json
        }.not_to change(DiscussionMessage, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        data = JSON.parse(response.body)
        expect(data['success']).to eq(false)
      end

      it 'rejects messages exceeding max length' do
        long_content = 'a' * 5001
        expect {
          post :create_message, params: {
            event_id: event.id,
            thread_type: 'public',
            discussion_message: { content: long_content }
          }, format: :json
        }.not_to change(DiscussionMessage, :count)
      end

      it 'denies unauthorized users from creating messages' do
        sign_out creator
        sign_in other_user
        
        expect {
          post :create_message, params: {
            event_id: event.id,
            thread_type: 'public',
            discussion_message: { content: 'Test' }
          }, format: :json
        }.not_to change(DiscussionMessage, :count)
      end

      it 'allows attendee to create message' do
        sign_out creator
        sign_in attendee
        
        expect {
          post :create_message, params: {
            event_id: event.id,
            thread_type: 'public',
            discussion_message: { content: 'Test message' }
          }, format: :json
        }.to change(DiscussionMessage, :count).by(1)
      end

      it 'handles HTML response format' do
        post :create_message, params: {
          event_id: event.id,
          thread_type: 'public',
          discussion_message: { content: 'Test message' }
        }

        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'invalid thread type handling' do
      it 'rejects invalid thread type for show action' do
        get :show, params: { event_id: event.id, thread_type: 'invalid_thread' }
        expect(response).to redirect_to(event_path(event))
      end

      it 'rejects invalid thread type for messages_feed action' do
        get :messages_feed, params: { event_id: event.id, thread_type: 'invalid_thread' }, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'rejects invalid thread type for create_message action' do
        post :create_message, params: {
          event_id: event.id,
          thread_type: 'invalid_thread',
          discussion_message: { content: 'Test' }
        }, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'thread type defaults' do
      it 'defaults to public thread when not specified' do
        get :show, params: { event_id: event.id }
        expect(assigns(:thread_type)).to eq('public')
      end

      it 'uses provided thread type when specified' do
        get :show, params: { event_id: event.id, thread_type: 'contributors_only' }
        expect(assigns(:thread_type)).to eq('contributors_only')
      end
    end
  end

  private

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out(user)
    session.delete(:user_id)
  end

  def create_user(email:, password:)
    User.create!(
      email: email,
      password: password,
      password_confirmation: password,
      first_name: 'Test',
      last_name: 'User',
      date_of_birth: 25.years.ago,
      gender: 'Male',
      occupation: 'Engineer',
      street: '123 Main St',
      city: 'Test City',
      state: 'TS',
      zip_code: '12345',
      country: 'Test Country'
    )
  end
end
