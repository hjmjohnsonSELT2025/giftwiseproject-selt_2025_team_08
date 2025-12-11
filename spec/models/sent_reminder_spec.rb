require 'rails_helper'

RSpec.describe SentReminder, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:event_id) }
    it { is_expected.to validate_presence_of(:timing) }

    describe 'reminder_type' do
      it { is_expected.to validate_presence_of(:reminder_type) }
      
      it 'accepts valid reminder types' do
        reminder = create(:sent_reminder, reminder_type: 'event')
        expect(reminder).to be_valid

        reminder = create(:sent_reminder, reminder_type: 'gift')
        expect(reminder).to be_valid
      end

      it 'rejects invalid reminder types' do
        reminder = build(:sent_reminder, reminder_type: 'invalid', user: create(:user), event: create(:event))
        expect(reminder).not_to be_valid
        expect(reminder.errors[:reminder_type]).to be_present
      end
    end
  end

  describe 'uniqueness constraint' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    it 'prevents duplicate reminders for the same user, event, and type' do
      reminder = create(:sent_reminder, user: user, event: event, reminder_type: 'event', timing: 'day_before')
      duplicate = build(:sent_reminder, user: user, event: event, reminder_type: 'event', timing: 'day_before')
      
      expect { duplicate.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'allows different reminder types for the same user and event' do
      create(:sent_reminder, user: user, event: event, reminder_type: 'event', timing: 'day_before')
      
      gift_reminder = build(:sent_reminder, user: user, event: event, reminder_type: 'gift', timing: 'week_before')
      expect(gift_reminder).to be_valid
    end

    it 'allows same reminder type for different events' do
      event2 = create(:event)
      create(:sent_reminder, user: user, event: event, reminder_type: 'event', timing: 'day_before')
      
      different_event = build(:sent_reminder, user: user, event: event2, reminder_type: 'event', timing: 'day_before')
      expect(different_event).to be_valid
    end
  end
end
