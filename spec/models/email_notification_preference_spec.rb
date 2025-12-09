require 'rails_helper'

RSpec.describe EmailNotificationPreference, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    let(:user) { create(:user) }

    it 'validates uniqueness of user_id' do
      user = create(:user)
      create(:email_notification_preference, user: user)
      preference = build(:email_notification_preference, user: user)
      expect(preference).not_to be_valid
      expect(preference.errors[:user_id]).to be_present
    end

    describe 'event_reminder_timing' do
      it 'accepts valid timing options' do
        preference = build(:email_notification_preference, event_reminder_timing: 'week_before')
        expect(preference).to be_valid
      end

      it 'rejects invalid timing options' do
        preference = build(:email_notification_preference, event_reminder_timing: 'invalid_timing')
        expect(preference).not_to be_valid
        expect(preference.errors[:event_reminder_timing]).to be_present
      end

      it 'allows nil value' do
        preference = build(:email_notification_preference, event_reminder_timing: nil)
        expect(preference).to be_valid
      end
    end

    describe 'gift_reminder_timing' do
      it 'accepts valid timing options' do
        preference = build(:email_notification_preference, gift_reminder_timing: 'two_weeks_before')
        expect(preference).to be_valid
      end

      it 'rejects invalid timing options' do
        preference = build(:email_notification_preference, gift_reminder_timing: 'invalid_timing')
        expect(preference).not_to be_valid
        expect(preference.errors[:gift_reminder_timing]).to be_present
      end

      it 'allows nil value' do
        preference = build(:email_notification_preference, gift_reminder_timing: nil)
        expect(preference).to be_valid
      end
    end
  end

  describe 'TIMING_OPTIONS' do
    it 'includes all required timing options' do
      expected_options = [
        'at_time', 'day_of', 'day_before', 'two_days_before',
        'week_before', 'two_weeks_before', 'month_before'
      ]
      expected_options.each do |option|
        expect(EmailNotificationPreference::TIMING_OPTIONS.keys).to include(option)
      end
    end

    it 'provides human-readable descriptions' do
      expect(EmailNotificationPreference::TIMING_OPTIONS['week_before']).to eq('Week Before')
      expect(EmailNotificationPreference::TIMING_OPTIONS['month_before']).to eq('A Month Before')
    end
  end

  describe 'defaults' do
    let(:preference) { create(:email_notification_preference) }

    it 'defaults reminders to enabled' do
      expect(preference.event_reminders_enabled).to be true
      expect(preference.gift_reminders_enabled).to be true
    end

    it 'has default timing values' do
      expect(preference.event_reminder_timing).to eq('day_before')
      expect(preference.gift_reminder_timing).to eq('week_before')
    end
  end
end
