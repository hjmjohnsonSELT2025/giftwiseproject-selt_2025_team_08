require 'rails_helper'

RSpec.describe WishListItem, type: :model do
  let(:user) { create(:user) }

  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(1).is_at_most(1000) }
    
    it { should allow_value(nil).for(:description) }
    it { should allow_value('').for(:description) }
    it { should validate_length_of(:description).is_at_most(1000) }
    
    it { should allow_value(nil).for(:url) }
    it { should allow_value('').for(:url) }
    
    it { should allow_value(nil).for(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

    it 'validates URL format' do
      item = build(:wish_list_item, url: 'invalid-url')
      expect(item).not_to be_valid
      expect(item.errors[:url]).to include('must be a valid URL')

      item = build(:wish_list_item, url: 'https://example.com')
      expect(item).to be_valid
    end

    it 'ensures unique name per user' do
      create(:wish_list_item, user: user, name: 'Laptop')
      item = build(:wish_list_item, user: user, name: 'Laptop')
      expect(item).not_to be_valid
      expect(item.errors[:user_id]).to include('can only have one item with this name')
    end

    it 'allows same name for different users' do
      user2 = create(:user)
      create(:wish_list_item, user: user, name: 'Laptop')
      item = build(:wish_list_item, user: user2, name: 'Laptop')
      expect(item).to be_valid
    end
  end

  context 'max items per user validation' do
    it 'allows up to 10 items' do
      10.times do |i|
        item = create(:wish_list_item, user: user, name: "Item #{i}")
        expect(item).to be_persisted
      end
    end

    it 'does not allow more than 10 items' do
      10.times do |i|
        create(:wish_list_item, user: user, name: "Item #{i}")
      end

      item = build(:wish_list_item, user: user, name: 'Item 11')
      expect(item).not_to be_valid
      expect(item.errors[:base]).to include('You can only have up to 10 items in your wish list')
    end

    it 'allows update of existing items after reaching 10' do
      10.times do |i|
        create(:wish_list_item, user: user, name: "Item #{i}")
      end

      item = user.wish_list_items.first
      expect(item.update(description: 'Updated')).to be true
    end
  end
end
