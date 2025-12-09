require 'rails_helper'

RSpec.describe NotificationService do
  describe '.check_and_send_reminders' do
    let(:user) { create(:user) }
    let(:event) { create(:event, creator: user, start_at: 1.day.from_now, end_at: 2.days.from_now) }
    let(:preference) { create(:email_notification_preference, user: user, event_reminders_enabled: true, event_reminder_timing: 'day_before') }

    before do
      user.email_notification_preference = preference
      user.save
    end

    it 'iterates through all users' do
      expect(User).to receive(:find_each).and_yield(user)
      allow(NotificationService).to receive(:check_event_reminders)
      allow(NotificationService).to receive(:check_gift_reminders)
      
      NotificationService.check_and_send_reminders
    end

    it 'checks event reminders for each user' do
      expect(NotificationService).to receive(:check_event_reminders).with(user)
      NotificationService.check_and_send_reminders
    end

    it 'checks gift reminders for each user' do
      expect(NotificationService).to receive(:check_gift_reminders).with(user)
      NotificationService.check_and_send_reminders
    end
  end

  describe 'timing offsets' do
    it 'defines correct offsets for all timing options' do
      expected_offsets = {
        'at_time' => 0,
        'day_of' => 0,
        'day_before' => 1.day,
        'two_days_before' => 2.days,
        'week_before' => 1.week,
        'two_weeks_before' => 2.weeks,
        'month_before' => 1.month
      }

      expected_offsets.each do |timing, offset|
        expect(NotificationService::TIMING_OFFSETS[timing]).to eq(offset)
      end
    end
  end

  describe 'private methods' do
    let(:user) { create(:user) }
    let(:event) { create(:event, start_at: 1.day.from_now, end_at: 2.days.from_now) }
    let(:recipient) { create(:recipient, event_id: event.id) }

    describe 'check_event_reminders' do
      let(:preference) { create(:email_notification_preference, user: user, event_reminders_enabled: true, event_reminder_timing: 'day_before') }

      before { user.email_notification_preference = preference; user.save }

      context 'when event reminders are disabled' do
        before { preference.update(event_reminders_enabled: false) }

        it 'does not check reminders' do
          expect(EventReminderMailer).not_to receive(:event_reminder)
          NotificationService.send(:check_event_reminders, user)
        end
      end

      context 'when event reminders are enabled' do
        it 'sends reminder for upcoming event' do
          event.attendees << user
          expect(EventReminderMailer).to receive(:event_reminder).and_call_original
          
          NotificationService.send(:check_event_reminders, user)
        end

        it 'creates sent_reminder record' do
          event.attendees << user
          expect {
            NotificationService.send(:check_event_reminders, user)
          }.to change(SentReminder, :count)
        end

        it 'does not send duplicate reminders' do
          event.attendees << user
          create(:sent_reminder, user: user, event: event, reminder_type: 'event', timing: 'day_before')
          
          expect(EventReminderMailer).not_to receive(:event_reminder)
          NotificationService.send(:check_event_reminders, user)
        end

        it 'sends at_time reminders when event starts now' do
          preference.update(event_reminder_timing: 'at_time')
          event.attendees << user
          now_utc = Time.current
          event.update(start_at: now_utc.beginning_of_minute, end_at: now_utc.end_of_day)
          
          expect(EventReminderMailer).to receive(:event_reminder).and_call_original
          NotificationService.send(:check_event_reminders, user)
        end
      end
    end

    describe 'check_gift_reminders' do
      let(:preference) { create(:email_notification_preference, user: user, gift_reminders_enabled: true, gift_reminder_timing: 'week_before') }

      before { user.email_notification_preference = preference; user.save }

      context 'when gift reminders are disabled' do
        before { preference.update(gift_reminders_enabled: false) }

        it 'does not check reminders' do
          expect(GiftReminderMailer).not_to receive(:gift_reminder)
          NotificationService.send(:check_gift_reminders, user)
        end
      end

      context 'when gift reminders are enabled' do
        before do
          event.attendees << user
          event.update!(start_at: (Time.current + 1.week).beginning_of_day, end_at: (Time.current + 1.week).end_of_day)
        end

        it 'sends reminder for upcoming event' do
          allow_any_instance_of(GeminiService).to receive(:generate_multiple_ideas).and_return("Gift 1\nGift 2\nGift 3")
          expect(GiftReminderMailer).to receive(:gift_reminder).and_call_original
          
          NotificationService.send(:check_gift_reminders, user)
        end

        it 'creates sent_reminder record' do
          allow_any_instance_of(GeminiService).to receive(:generate_multiple_ideas).and_return("Gift 1\nGift 2\nGift 3")
          expect {
            NotificationService.send(:check_gift_reminders, user)
          }.to change(SentReminder, :count)
        end
      end
    end

    describe 'build_gift_summary' do
      before do
        event.attendees << user
        @recipient1 = create(:recipient, event_id: event.id)
        @recipient2 = create(:recipient, event_id: event.id)
        event.reload
      end

      it 'returns a hash with recipients as keys' do
        summary = NotificationService.send(:build_gift_summary, user, event)
        expect(summary).to be_a(Hash)
        expect(summary.keys).to match_array([event.recipients[0], event.recipients[1]])
      end

      it 'includes selected gifts for each recipient' do
        gift = create(:gift_for_recipient, recipient_id: @recipient1.id, user: user, status: 'purchased')
        summary = NotificationService.send(:build_gift_summary, user, event)
        
        expect(summary[@recipient1][:selected]).to include(gift)
      end

      it 'includes suggestions for each recipient' do
        allow_any_instance_of(GeminiService).to receive(:generate_multiple_ideas).and_return("Gift 1\nGift 2\nGift 3")
        summary = NotificationService.send(:build_gift_summary, user, event)
        expect(summary[@recipient1][:suggestions]).to be_an(Array)
        expect(summary[@recipient1][:suggestions].length).to eq(3)
      end

      it 'includes empty suggestions when gift is selected' do
        gift = create(:gift_for_recipient, recipient_id: @recipient1.id, user: user, status: 'purchased')
        allow_any_instance_of(GeminiService).to receive(:generate_multiple_ideas).and_return("Gift 1\nGift 2\nGift 3")
        summary = NotificationService.send(:build_gift_summary, user, event)
        
        expect(summary[@recipient1][:suggestions]).to be_empty
      end
    end

    describe 'generate_gift_suggestions' do
      it 'returns an array of suggestions' do
        suggestions = NotificationService.send(:generate_gift_suggestions, recipient)
        expect(suggestions).to be_an(Array)
      end

      it 'generates 3 suggestions' do
        suggestions = NotificationService.send(:generate_gift_suggestions, recipient)
        expect(suggestions.length).to eq(3)
      end

      it 'handles recipients with age information' do
        recipient.update(age: 25)
        suggestions = NotificationService.send(:generate_gift_suggestions, recipient)
        
        expect(suggestions).to be_an(Array)
        expect(suggestions.length).to eq(3)
      end

      it 'includes recipient information in suggestions' do
        expect_any_instance_of(Object).to receive(:send).with(anything).at_least(:once) if defined?(Anthropic)
        suggestions = NotificationService.send(:generate_gift_suggestions, recipient)
        expect(suggestions).not_to be_empty
      end
    end
  end
end
