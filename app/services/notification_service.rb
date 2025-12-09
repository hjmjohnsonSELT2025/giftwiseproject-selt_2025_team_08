class NotificationService
  TIMING_OFFSETS = {
    'at_time' => 0,
    'day_of' => 0.days,
    'day_before' => 1.day,
    'two_days_before' => 2.days,
    'week_before' => 1.week,
    'two_weeks_before' => 2.weeks,
    'month_before' => 1.month
  }.freeze

  class << self
    def check_and_send_reminders
      User.find_each do |user|
        check_event_reminders(user)
        check_gift_reminders(user)
      end
    end

    private

    def check_event_reminders(user)
      preferences = user.email_notification_preference
      
      cst_time = Time.current.in_time_zone('America/Chicago')
      Rails.logger.info "[Notification] Checking event reminders for #{user.email} at #{cst_time}"
      
      return unless preferences&.event_reminders_enabled?
      Rails.logger.info "[Notification] Event reminders enabled for #{user.email}"
      return unless preferences.event_reminder_timing.present?
      Rails.logger.info "[Notification] Reminder timing: #{preferences.event_reminder_timing}"

      events = upcoming_events(user, preferences.event_reminder_timing)
      Rails.logger.info "[Notification] Found #{events.count} upcoming events for #{user.email}"
      
      events.each do |event|
        Rails.logger.info "[Notification]   - Event: #{event.name} (#{event.id}) starts at #{event.start_at}"
        next if SentReminder.exists?(user: user, event: event, reminder_type: 'event')
        Rails.logger.info "[Notification]     Sending email for event #{event.id}"

        EventReminderMailer.event_reminder(user, event).deliver_now
        SentReminder.create!(
          user: user,
          event: event,
          reminder_type: 'event',
          timing: preferences.event_reminder_timing
        )
        Rails.logger.info "[Notification]     Email sent successfully!"
      end
    end

    def check_gift_reminders(user)
      preferences = user.email_notification_preference
      return unless preferences&.gift_reminders_enabled?
      return unless preferences.gift_reminder_timing.present?

      upcoming_events(user, preferences.gift_reminder_timing).each do |event|
        next if SentReminder.exists?(user: user, event: event, reminder_type: 'gift')

        gift_summary = build_gift_summary(user, event)
        GiftReminderMailer.gift_reminder(user, event, gift_summary).deliver_now
        SentReminder.create!(
          user: user,
          event: event,
          reminder_type: 'gift',
          timing: preferences.gift_reminder_timing
        )
      end
    end

    def upcoming_events(user, timing)
      offset = TIMING_OFFSETS[timing]
      cst_time = Time.current.in_time_zone('America/Chicago')
      
      if timing == 'at_time'
        now = Time.current
        minute_start = now.beginning_of_minute
        minute_end = minute_start + 1.minute
        
        Rails.logger.info "[Notification]   Looking for events starting between #{minute_start} and #{minute_end} (CST: #{cst_time.beginning_of_minute} - #{(cst_time.beginning_of_minute + 1.minute)})"
        
        events = Event.where("creator_id = ? OR id IN (SELECT event_id FROM event_attendees WHERE user_id = ?)", user.id, user.id)
        results = events.where("(start_at >= ? AND start_at < ?) OR (start_at < ? AND end_at > ?)", 
                     minute_start, minute_end, now, now)
        
        Rails.logger.info "[Notification]   Event query SQL: creator_id = #{user.id} OR in attendees"
        Rails.logger.info "[Notification]   Found #{results.count} events matching time criteria"
        results
      else
        target_time_start = (Time.current + offset).beginning_of_day
        target_time_end = target_time_start.end_of_day
        
        Event.where("creator_id = ? OR id IN (SELECT event_id FROM event_attendees WHERE user_id = ?)", user.id, user.id)
             .where("start_at >= ? AND start_at <= ?", target_time_start, target_time_end)
      end
    end

    def build_gift_summary(user, event)
      summary = {}
      
      event.recipients.each do |recipient|
        gifts_for_recipient = recipient.gifts_for_recipients.where(user: user)
        selected_gift = gifts_for_recipient.where(status: ['purchased', 'delivered', 'wrapped', 'liked']).first

        gift_data = {
          selected: selected_gift ? [selected_gift] : [],
          suggestions: []
        }

        unless selected_gift
          gift_data[:suggestions] = generate_gift_suggestions(recipient)
        end

        summary[recipient] = gift_data
      end

      summary
    end

    def generate_gift_suggestions(recipient)
      prompt_parts = ["Generate three creative and thoughtful gift ideas for"]
      prompt_parts << "a #{recipient.age}-year-old" if recipient.age.present?
      prompt = prompt_parts.join(" ") + "."
      
      if recipient.hobbies.present?
        prompt += " Their hobbies include: #{recipient.hobbies}."
      end
      
      if recipient.likes.present?
        prompt += " They enjoy: #{recipient.likes}."
      end
      
      if recipient.dislikes.present?
        prompt += " They dislike: #{recipient.dislikes}."
      end
      
      prompt += " Please provide exactly 3 gift ideas, one per line, with no numbering or explanations."

      begin
        service = GeminiService.new
        ideas = service.generate_multiple_ideas(prompt)
        ideas.split("\n").map(&:strip).reject(&:blank?).first(3)
      rescue StandardError => e
        Rails.logger.error("Error generating gift suggestions: #{e.message}")
        ["Gift Card", "Book", "Tech Accessory"]
      end
    end
  end
end
