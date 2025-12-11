require 'rails_helper'

RSpec.describe EventReminderMailer, type: :mailer do
  describe '#event_reminder' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }
    let(:mail) { EventReminderMailer.event_reminder(user, event) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Reminder: #{event.name} is coming up!")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to include(ENV["MAILER_FROM_EMAIL"] || "noreply@giftwiseapp.com")
    end

    it 'renders the body with event details' do
      expect(mail.body.encoded).to include(user.first_name)
      expect(mail.body.encoded).to include(event.name)
      expect(mail.body.encoded).to include(event.theme)
    end

    it 'includes recipient count in the body' do
      create_list(:recipient, 3, event_id: event.id)
      mail_with_recipients = EventReminderMailer.event_reminder(user, event)
      expect(mail_with_recipients.body.encoded).to include('3')
    end

    it 'includes list of recipients' do
      recipient1 = create(:recipient, event_id: event.id, first_name: 'Alice', last_name: 'Smith')
      recipient2 = create(:recipient, event_id: event.id, first_name: 'Bob', last_name: 'Johnson')
      mail_with_recipients = EventReminderMailer.event_reminder(user, event)
      
      expect(mail_with_recipients.body.encoded).to include('Alice Smith')
      expect(mail_with_recipients.body.encoded).to include('Bob Johnson')
    end

    it 'handles events with no recipients gracefully' do
      expect(mail.body.encoded).to include('No recipients for this event.')
    end

    context 'multipart email' do
      it 'generates both html and text parts' do
        expect(mail.content_type).to include('multipart/alternative')
      end

      it 'renders html template' do
        expect(mail.html_part).to be_present
        expect(mail.html_part.body.encoded).to include('<h1>Event Reminder</h1>')
      end

      it 'renders text template' do
        expect(mail.text_part).to be_present
        expect(mail.text_part.body.encoded).to include('Event Reminder')
      end
    end

    context 'with special characters in event name' do
      let(:event_with_special_chars) { create(:event, name: "Sally's 50th Birthday & Celebration!") }
      
      it 'handles special characters correctly' do
        mail = EventReminderMailer.event_reminder(user, event_with_special_chars)
        expect(mail.subject).to include(event_with_special_chars.name)
      end
    end
  end
end
