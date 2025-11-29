require 'rails_helper'

RSpec.describe GiftForRecipient, type: :model do
  let(:user) { create_user(email: 'user@example.com', password: 'password123') }
  let(:user2) { create_user(email: 'user2@example.com', password: 'password123') }
  let(:event) { create(:event, creator: user) }
  let(:recipient) { event.recipients.create!(first_name: 'John', last_name: 'Doe') }

  describe 'associations' do
    it { should belong_to(:recipient) }
    it { should belong_to(:user) }
  end

  describe 'table name' do
    it 'uses the correct table name' do
      expect(GiftForRecipient.table_name).to eq('gifts_for_recipients')
    end
  end

  describe 'creation' do
    it 'can record a gift with valid attributes' do
      gift = recipient.gifts_for_recipients.build(
        idea: 'A watch',
        price: 150,
        gift_date: Date.today,
        user: user
      )
      expect(gift.save).to be_truthy
    end

    it 'requires an idea' do
      gift = recipient.gifts_for_recipients.build(user: user)
      expect(gift.save).to be_falsy
    end

    it 'allows optional price' do
      gift = recipient.gifts_for_recipients.create!(
        idea: 'A book',
        user: user
      )
      expect(gift.price).to be_nil
    end

    it 'allows optional gift_date' do
      gift = recipient.gifts_for_recipients.create!(
        idea: 'A watch',
        gift_date: nil,
        user: user
      )
      expect(gift.gift_date).to be_nil
    end
  end

  describe 'user-specific gift tracking' do
    it 'each user can record their own gift for the same recipient' do
      gift1 = recipient.gifts_for_recipients.create!(idea: 'Book', price: 20, gift_date: Date.today, user: user)
      gift2 = recipient.gifts_for_recipients.create!(idea: 'Watch', price: 150, gift_date: Date.today, user: user2)
      
      expect(recipient.gifts_for_recipients.where(user: user).count).to eq(1)
      expect(recipient.gifts_for_recipients.where(user: user2).count).to eq(1)
    end

    it 'retrieves only the current users gifts for a recipient' do
      recipient.gifts_for_recipients.create!(idea: 'Book', gift_date: Date.today, user: user)
      recipient.gifts_for_recipients.create!(idea: 'Watch', gift_date: Date.today, user: user)
      recipient.gifts_for_recipients.create!(idea: 'Shoes', gift_date: Date.today, user: user2)
      
      user_gifts = recipient.gifts_for_recipients.where(user: user)
      expect(user_gifts.count).to eq(2)
      expect(user_gifts.pluck(:idea)).to match_array(['Book', 'Watch'])
    end

    it 'can retrieve only the most recent gift for a user' do
      gift1 = recipient.gifts_for_recipients.create!(idea: 'Book', user: user, gift_date: '2025-01-01')
      gift2 = recipient.gifts_for_recipients.create!(idea: 'Watch', user: user, gift_date: '2025-11-01')
      
      user_gifts = recipient.gifts_for_recipients.where(user: user).limit(5)
      expect(user_gifts.last.idea).to eq('Watch')
    end
  end
end
