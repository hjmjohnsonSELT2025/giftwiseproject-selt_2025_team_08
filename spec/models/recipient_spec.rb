require 'rails_helper'

RSpec.describe Recipient, type: :model do
  let(:user) { create_user(email: 'user@example.com', password: 'password123') }
  let(:event) { create(:event, creator: user) }

  describe 'associations' do
    it { should belong_to(:event) }
    it { should have_many(:gift_ideas).dependent(:destroy) }
    it { should have_many(:gifts_for_recipients).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'creation' do
    it 'can create a recipient with valid attributes' do
      recipient = event.recipients.build(
        first_name: 'John',
        last_name: 'Doe',
        age: 30,
        occupation: 'Engineer',
        hobbies: 'Reading',
        likes: 'Coffee',
        dislikes: 'Spicy food'
      )
      expect(recipient.save).to be_truthy
    end

    it 'requires first_name and last_name' do
      recipient = event.recipients.build(age: 25)
      expect(recipient.save).to be_falsy
    end

    it 'has optional fields for age, occupation, hobbies, likes, and dislikes' do
      recipient = event.recipients.build(first_name: 'Jane', last_name: 'Smith')
      expect(recipient.save).to be_truthy
      expect(recipient.age).to be_nil
      expect(recipient.occupation).to be_nil
    end
  end

  describe 'deletion cascading' do
    it 'deletes associated gift ideas when recipient is deleted' do
      recipient = event.recipients.create!(first_name: 'John', last_name: 'Doe')
      gift_idea = recipient.gift_ideas.create!(idea: 'A book', user: user)
      
      expect { recipient.destroy }.to change(GiftIdea, :count).by(-1)
    end

    it 'deletes associated gifts for recipients when recipient is deleted' do
      recipient = event.recipients.create!(first_name: 'John', last_name: 'Doe')
      gift = recipient.gifts_for_recipients.create!(idea: 'A watch', gift_date: Date.today, user: user)
      
      expect { recipient.destroy }.to change(GiftForRecipient, :count).by(-1)
    end
  end
end
