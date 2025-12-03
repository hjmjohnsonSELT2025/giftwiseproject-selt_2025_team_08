require 'rails_helper'

RSpec.describe GiftIdea, type: :model do
  let(:user) { create_user(email: 'user@example.com', password: 'password123') }
  let(:event) { create(:event, creator: user) }
  let(:recipient) { event.recipients.create!(first_name: 'John', last_name: 'Doe') }

  describe 'associations' do
    it { should belong_to(:recipient) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:idea) }
    
    it 'allows valid https URLs for link' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        link: 'https://example.com/product'
      )
      expect(gift_idea).to be_valid
    end

    it 'allows valid http URLs for link' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        link: 'http://example.com'
      )
      expect(gift_idea).to be_valid
    end

    it 'allows nil link' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        link: nil
      )
      expect(gift_idea).to be_valid
    end

    it 'allows blank link' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        link: ''
      )
      expect(gift_idea).to be_valid
    end

    it 'rejects invalid URLs for link' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        link: 'not a valid url'
      )
      expect(gift_idea).not_to be_valid
      expect(gift_idea.errors[:link]).to be_present
    end

    it 'allows notes up to 255 characters' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        note: 'a' * 255
      )
      expect(gift_idea).to be_valid
    end

    it 'rejects notes exceeding 255 characters' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        note: 'a' * 256
      )
      expect(gift_idea).not_to be_valid
      expect(gift_idea.errors[:note]).to be_present
    end

    it 'allows nil note' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        note: nil
      )
      expect(gift_idea).to be_valid
    end

    it 'allows blank note' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Test idea',
        user: user,
        note: ''
      )
      expect(gift_idea).to be_valid
    end
  end

  describe 'creation' do
    it 'can create a gift idea with valid attributes' do
      gift_idea = recipient.gift_ideas.build(
        idea: 'Wireless headphones',
        estimated_price: 150,
        user: user,
        favorited: false
      )
      expect(gift_idea.save).to be_truthy
    end

    it 'requires an idea' do
      gift_idea = recipient.gift_ideas.build(user: user)
      expect(gift_idea.save).to be_falsy
    end

    it 'allows favoriting an idea' do
      gift_idea = recipient.gift_ideas.create!(
        idea: 'A book',
        user: user,
        favorited: true
      )
      expect(gift_idea.favorited).to be_truthy
    end

    it 'allows optional estimated_price' do
      gift_idea = recipient.gift_ideas.create!(
        idea: 'A watch',
        user: user
      )
      expect(gift_idea.estimated_price).to be_nil
    end

    it 'can create a gift idea with link and note' do
      gift_idea = recipient.gift_ideas.create!(
        idea: 'Smart watch',
        estimated_price: 299.99,
        user: user,
        link: 'https://example.com/smartwatch',
        note: 'Great battery life and features',
        favorited: true
      )
      expect(gift_idea).to be_persisted
      expect(gift_idea.link).to eq('https://example.com/smartwatch')
      expect(gift_idea.note).to eq('Great battery life and features')
    end

    it 'can create a gift idea without link and note' do
      gift_idea = recipient.gift_ideas.create!(
        idea: 'Generic gift',
        user: user,
        link: nil,
        note: nil
      )
      expect(gift_idea).to be_persisted
      expect(gift_idea.link).to be_nil
      expect(gift_idea.note).to be_nil
    end
  end

  describe 'updates' do
    let(:gift_idea) do
      recipient.gift_ideas.create!(
        idea: 'Original idea',
        user: user,
        estimated_price: 50.00,
        link: 'https://original.com'
      )
    end

    it 'can update the idea text' do
      gift_idea.update(idea: 'Updated idea')
      expect(gift_idea.reload.idea).to eq('Updated idea')
    end

    it 'can update the price' do
      gift_idea.update(estimated_price: 100.00)
      expect(gift_idea.reload.estimated_price).to eq(100.00)
    end

    it 'can update the link' do
      gift_idea.update(link: 'https://newlink.com/product')
      expect(gift_idea.reload.link).to eq('https://newlink.com/product')
    end

    it 'can add a note' do
      gift_idea.update(note: 'New note added')
      expect(gift_idea.reload.note).to eq('New note added')
    end

    it 'can update the note' do
      gift_idea.update(note: 'Original note')
      gift_idea.update(note: 'Updated note')
      expect(gift_idea.reload.note).to eq('Updated note')
    end

    it 'can clear the link' do
      gift_idea.update(link: nil)
      expect(gift_idea.reload.link).to be_nil
    end

    it 'can clear the note' do
      gift_idea.update(note: 'Something')
      gift_idea.update(note: nil)
      expect(gift_idea.reload.note).to be_nil
    end
  end

  describe 'user-specific gift ideas' do
    let(:user2) { create_user(email: 'user2@example.com', password: 'password123') }

    it 'can have different users with different ideas for same recipient' do
      idea1 = recipient.gift_ideas.create!(idea: 'Book from user1', user: user, favorited: true)
      idea2 = recipient.gift_ideas.create!(idea: 'Watch from user2', user: user2, favorited: true)
      
      user_ideas = recipient.gift_ideas.where(user: user, favorited: true)
      user2_ideas = recipient.gift_ideas.where(user: user2, favorited: true)
      
      expect(user_ideas.count).to eq(1)
      expect(user2_ideas.count).to eq(1)
      expect(user_ideas.first.idea).to eq('Book from user1')
      expect(user2_ideas.first.idea).to eq('Watch from user2')
    end

    it 'can retrieve only favorited ideas for a specific user' do
      recipient.gift_ideas.create!(idea: 'Unfavorited book', user: user, favorited: false)
      recipient.gift_ideas.create!(idea: 'Favorited watch', user: user, favorited: true)
      
      user_favorited = recipient.gift_ideas.where(user: user, favorited: true)
      expect(user_favorited.count).to eq(1)
      expect(user_favorited.first.idea).to eq('Favorited watch')
    end

    it 'preserves link and note when saved by different users' do
      idea1 = recipient.gift_ideas.create!(
        idea: 'Book',
        user: user,
        link: 'https://book.com',
        note: 'User 1 note',
        favorited: true
      )
      idea2 = recipient.gift_ideas.create!(
        idea: 'Same product different user',
        user: user2,
        link: 'https://book.com',
        note: 'User 2 note',
        favorited: true
      )
      
      expect(idea1.reload.link).to eq('https://book.com')
      expect(idea1.reload.note).to eq('User 1 note')
      expect(idea2.reload.link).to eq('https://book.com')
      expect(idea2.reload.note).to eq('User 2 note')
    end
  end
end
