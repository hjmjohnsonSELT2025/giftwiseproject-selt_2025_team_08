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
  end
end
