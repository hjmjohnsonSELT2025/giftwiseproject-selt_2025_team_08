require 'rails_helper'

RSpec.describe DiscussionMessage, type: :model do
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

  let(:discussion) do
    Discussion.create!(event_id: event.id, thread_type: 'public')
  end

  describe 'associations' do
    it 'belongs to discussion' do
      expect(DiscussionMessage.new.respond_to?(:discussion)).to be true
    end

    it 'belongs to user' do
      expect(DiscussionMessage.new.respond_to?(:user)).to be true
    end

    it 'can access discussion through association' do
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Test message'
      )
      expect(message.discussion).to eq(discussion)
    end

    it 'can access user through association' do
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Test message'
      )
      expect(message.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'requires discussion_id' do
      message = DiscussionMessage.new(user_id: user.id, content: 'Test')
      expect(message.valid?).to be false
      expect(message.errors[:discussion_id]).to be_present
    end

    it 'requires user_id' do
      message = DiscussionMessage.new(discussion_id: discussion.id, content: 'Test')
      expect(message.valid?).to be false
      expect(message.errors[:user_id]).to be_present
    end

    it 'requires content' do
      message = DiscussionMessage.new(discussion_id: discussion.id, user_id: user.id)
      expect(message.valid?).to be false
      expect(message.errors[:content]).to be_present
    end

    it 'rejects empty content' do
      message = DiscussionMessage.new(
        discussion_id: discussion.id,
        user_id: user.id,
        content: ''
      )
      expect(message.valid?).to be false
      expect(message.errors[:content]).to be_present
    end

    it 'enforces minimum content length' do
      message = DiscussionMessage.new(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'a' * 0
      )
      expect(message.valid?).to be false
    end

    it 'enforces maximum content length' do
      message = DiscussionMessage.new(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'a' * 5001
      )
      expect(message.valid?).to be false
      expect(message.errors[:content]).to be_present
    end

    it 'allows content at maximum length' do
      message = DiscussionMessage.new(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'a' * 5000
      )
      expect(message.valid?).to be true
    end

    it 'allows content with single character' do
      message = DiscussionMessage.new(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'a'
      )
      expect(message.valid?).to be true
    end
  end

  describe 'creating messages' do
    it 'creates a message with valid attributes' do
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Test message'
      )
      expect(message.persisted?).to be true
      expect(message.discussion_id).to eq(discussion.id)
      expect(message.user_id).to eq(user.id)
      expect(message.content).to eq('Test message')
    end

    it 'tracks creation timestamp' do
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Test message'
      )
      expect(message.created_at).not_to be_nil
      expect(message.updated_at).not_to be_nil
    end

    it 'preserves content exactly as provided' do
      content = "Message with\nnewlines and    spaces"
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: content
      )
      expect(message.content).to eq(content)
    end

    it 'preserves special characters in content' do
      content = "Message with special chars: <>&\"'"
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: content
      )
      expect(message.content).to eq(content)
    end
  end

  describe 'ordered scope' do
    it 'returns messages in ascending order by created_at' do
      msg1 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'First'
      )
      msg2 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Second'
      )
      msg3 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Third'
      )

      ordered_messages = DiscussionMessage.ordered
      expect(ordered_messages.pluck(:id)).to eq([msg1.id, msg2.id, msg3.id])
    end
  end

  describe 'multiple users' do
    let(:user2) do
      User.create!(
        email: 'user2@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'Test2',
        last_name: 'User2',
        date_of_birth: 25.years.ago,
        gender: 'Female',
        occupation: 'Doctor',
        street: '456 Main St',
        city: 'Test City',
        state: 'TS',
        zip_code: '12345',
        country: 'Test Country'
      )
    end

    it 'allows multiple users to post messages in same discussion' do
      msg1 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'User 1 message'
      )
      msg2 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user2.id,
        content: 'User 2 message'
      )

      expect(discussion.messages.count).to eq(2)
      expect(discussion.messages).to include(msg1, msg2)
    end

    it 'tracks which user posted each message' do
      msg1 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'User 1 message'
      )
      msg2 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user2.id,
        content: 'User 2 message'
      )

      expect(msg1.user_id).to eq(user.id)
      expect(msg2.user_id).to eq(user2.id)
      expect(msg1.user).to eq(user)
      expect(msg2.user).to eq(user2)
    end
  end

  describe 'discussion message deletion' do
    it 'can be deleted independently' do
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Test message'
      )
      message_id = message.id

      message.destroy
      expect(DiscussionMessage.exists?(message_id)).to be false
      expect(Discussion.exists?(discussion.id)).to be true
    end

    it 'discussion persists when message is deleted' do
      msg1 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Message 1'
      )
      msg2 = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Message 2'
      )

      msg1.destroy
      expect(discussion.messages.count).to eq(1)
      expect(discussion.messages.first).to eq(msg2)
    end
  end

  describe 'content sanitization' do
    it 'stores content with leading/trailing whitespace' do
      content = "  Message with spaces  "
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: content
      )
      expect(message.content).to eq(content)
    end

    it 'allows unicode characters' do
      content = "Message with unicode: 你好 مرحبا"
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: content
      )
      expect(message.content).to eq(content)
    end

    it 'allows emojis' do
      content = "Message with emoji: 😀 🎉 👍"
      message = DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: content
      )
      expect(message.content).to eq(content)
    end
  end

  describe 'eager loading with user' do
    it 'can eager load user information' do
      DiscussionMessage.create!(
        discussion_id: discussion.id,
        user_id: user.id,
        content: 'Test message'
      )

      messages = DiscussionMessage.eager_load(:user).ordered
      message = messages.first
      
      expect(message.user.first_name).to eq('Test')
      expect(message.user.last_name).to eq('User')
    end
  end
end
