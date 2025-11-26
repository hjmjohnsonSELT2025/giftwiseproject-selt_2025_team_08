require 'rails_helper'

RSpec.describe EventAttendee, type: :model do
  let(:user1) { create_user(email: 'user1@example.com', password: 'password123') }
  let(:user2) { create_user(email: 'user2@example.com', password: 'password123') }
  let(:event) { create(:event, creator: user1) }

  describe 'associations' do
    it { should belong_to(:event) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it 'validates uniqueness of user_id scoped to event_id' do
      event.event_attendees.create!(user: user1)
      duplicate = event.event_attendees.build(user: user1)
      expect(duplicate.save).to be_falsy
    end
  end

  describe 'creation' do
    it 'can add an attendee to an event' do
      attendee = event.event_attendees.build(user: user2)
      expect(attendee.save).to be_truthy
    end

    it 'prevents duplicate attendees on the same event' do
      event.event_attendees.create!(user: user2)
      duplicate = event.event_attendees.build(user: user2)
      expect(duplicate.save).to be_falsy
    end

    it 'allows the same user to attend different events' do
      event1 = create(:event, creator: user1)
      event2 = create(:event, creator: user1)
      
      event1.event_attendees.create!(user: user2)
      event2.event_attendees.create!(user: user2)
      
      expect(event1.event_attendees.where(user: user2).count).to eq(1)
      expect(event2.event_attendees.where(user: user2).count).to eq(1)
    end
  end

  describe 'deletion' do
    it 'can remove an attendee from an event' do
      attendee = event.event_attendees.create!(user: user2)
      expect { attendee.destroy }.to change(EventAttendee, :count).by(-1)
    end
  end
end
