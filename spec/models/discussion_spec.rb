require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let(:user) do
    User.create!(
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
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

  let(:event) do
    Event.create!(
      name: 'Test Event',
      description: 'Test Description',
      start_at: Time.current + 1.day,
      end_at: Time.current + 2.days,
      creator_id: user.id,
      theme: 'General'
    )
  end

  describe 'associations' do
    it 'belongs to event' do
      expect(Discussion.new.respond_to?(:event)).to be true
    end

    it 'has many messages' do
      expect(Discussion.new.respond_to?(:messages)).to be true
    end

    it 'destroys messages when deleted' do
      discussion = Discussion.create!(event_id: event.id, thread_type: 'public')
      message = DiscussionMessage.create!(discussion_id: discussion.id, user_id: user.id, content: 'Test')
      
      discussion.destroy
      expect(DiscussionMessage.exists?(message.id)).to be false
    end
  end

  describe 'validations' do
    it 'requires event_id' do
      discussion = Discussion.new(thread_type: 'public')
      expect(discussion.valid?).to be false
      expect(discussion.errors[:event_id]).to be_present
    end

    it 'requires thread_type' do
      discussion = Discussion.new(event_id: event.id, thread_type: nil)
      expect(discussion.valid?).to be false
      expect(discussion.errors[:thread_type]).to be_present
    end

    it 'validates thread_type inclusion' do
      discussion = Discussion.new(event_id: event.id, thread_type: 'invalid_type')
      expect(discussion.valid?).to be false
      expect(discussion.errors[:thread_type]).to be_present
    end

    it 'allows public thread_type' do
      discussion = Discussion.new(event_id: event.id, thread_type: 'public')
      expect(discussion.valid?).to be true
    end

    it 'allows contributors_only thread_type' do
      discussion = Discussion.new(event_id: event.id, thread_type: 'contributors_only')
      expect(discussion.valid?).to be true
    end

    it 'enforces uniqueness of event_id and thread_type combination' do
      Discussion.create!(event_id: event.id, thread_type: 'public')
      duplicate = Discussion.new(event_id: event.id, thread_type: 'public')
      
      expect(duplicate.valid?).to be false
      expect(duplicate.errors[:event_id]).to be_present
    end

    it 'allows multiple thread types for same event' do
      Discussion.create!(event_id: event.id, thread_type: 'public')
      contributors = Discussion.new(event_id: event.id, thread_type: 'contributors_only')
      
      expect(contributors.valid?).to be true
    end
  end

  describe 'scopes' do
    let!(:public_discussion) { Discussion.create!(event_id: event.id, thread_type: 'public') }
    let!(:contributors_discussion) { Discussion.create!(event_id: event.id, thread_type: 'contributors_only') }

    describe 'public_thread scope' do
      it 'returns only public discussions' do
        results = Discussion.public_thread
        expect(results).to include(public_discussion)
        expect(results).not_to include(contributors_discussion)
      end
    end

    describe 'contributors_only_thread scope' do
      it 'returns only contributors_only discussions' do
        results = Discussion.contributors_only_thread
        expect(results).to include(contributors_discussion)
        expect(results).not_to include(public_discussion)
      end
    end
  end

  describe 'THREAD_TYPES constant' do
    it 'includes public' do
      expect(Discussion::THREAD_TYPES).to include('public')
    end

    it 'includes contributors_only' do
      expect(Discussion::THREAD_TYPES).to include('contributors_only')
    end

    it 'has exactly 2 thread types' do
      expect(Discussion::THREAD_TYPES.length).to eq(2)
    end
  end

  describe 'creating discussions' do
    it 'creates a discussion for an event' do
      discussion = Discussion.create!(event_id: event.id, thread_type: 'public')
      expect(discussion.event_id).to eq(event.id)
      expect(discussion.thread_type).to eq('public')
    end

    it 'tracks creation timestamp' do
      discussion = Discussion.create!(event_id: event.id, thread_type: 'public')
      expect(discussion.created_at).not_to be_nil
      expect(discussion.updated_at).not_to be_nil
    end
  end

  describe 'messages association' do
    let(:discussion) { Discussion.create!(event_id: event.id, thread_type: 'public') }

    it 'can have multiple messages' do
      3.times do |i|
        DiscussionMessage.create!(discussion_id: discussion.id, user_id: user.id, content: "Message #{i}")
      end

      expect(discussion.messages.count).to eq(3)
    end

    it 'returns messages in order' do
      msg1 = DiscussionMessage.create!(discussion_id: discussion.id, user_id: user.id, content: 'First')
      msg2 = DiscussionMessage.create!(discussion_id: discussion.id, user_id: user.id, content: 'Second')
      
      expect(discussion.messages.ordered.pluck(:content)).to eq(['First', 'Second'])
    end
  end
end
