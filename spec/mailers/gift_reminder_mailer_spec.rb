require 'rails_helper'

RSpec.describe GiftReminderMailer, type: :mailer do
  describe '#gift_reminder' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }
    let(:recipient) { create(:recipient, event_id: event.id) }
    let(:gift_summary) do
      {
        recipient => {
          selected: [],
          suggestions: ['Gift Idea 1', 'Gift Idea 2', 'Gift Idea 3']
        }
      }
    end
    let(:mail) { GiftReminderMailer.gift_reminder(user, event, gift_summary) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Gift Reminder: Get ready for #{event.name}!")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to include(ENV["MAILER_FROM_EMAIL"] || "noreply@giftwiseapp.com")
    end

    it 'renders the body with event details' do
      expect(mail.body.encoded).to include(user.first_name)
      expect(mail.body.encoded).to include(event.name)
    end

    it 'includes gift summary in the body' do
      expect(mail.body.encoded).to include('Gift Idea 1')
      expect(mail.body.encoded).to include('Gift Idea 2')
      expect(mail.body.encoded).to include('Gift Idea 3')
    end

    context 'with selected gifts' do
      let(:gift_summary_with_selected) do
        gift = create(:gift_for_recipient, recipient_id: recipient.id, idea: 'Gold Watch', price: 99.99)
        {
          recipient => {
            selected: [gift],
            suggestions: []
          }
        }
      end

      it 'displays selected gifts with price' do
        mail = GiftReminderMailer.gift_reminder(user, event, gift_summary_with_selected)
        expect(mail.body.encoded).to include('Gold Watch')
        expect(mail.body.encoded).to include('99.99')
      end

      it 'displays checkmark for selected gifts' do
        mail = GiftReminderMailer.gift_reminder(user, event, gift_summary_with_selected)
        expect(mail.body.encoded).to match(/✓|checkmark|selected/i)
      end
    end

    context 'with no selected gifts' do
      it 'displays X indicator for unselected gifts' do
        expect(mail.body.encoded).to match(/✗|no.*selected/i)
      end

      it 'includes suggested gift ideas' do
        expect(mail.body.encoded).to include('Suggested Gift Ideas')
        expect(mail.body.encoded).to include('Gift Idea 1')
      end
    end

    context 'multipart email' do
      it 'generates both html and text parts' do
        expect(mail.content_type).to include('multipart/alternative')
      end

      it 'renders html template' do
        expect(mail.html_part).to be_present
        expect(mail.html_part.body.encoded).to include('<h1>Gift Reminder')
      end

      it 'renders text template' do
        expect(mail.text_part).to be_present
        expect(mail.text_part.body.encoded).to include('Gift Reminder')
      end
    end

    context 'with multiple recipients' do
      it 'displays all recipient gift statuses' do
        recipient2 = create(:recipient, event_id: event.id, first_name: 'Jane', last_name: 'Doe')
        gift_summary_multi = {
          recipient => {
            selected: [],
            suggestions: ['Suggestion 1']
          },
          recipient2 => {
            selected: [],
            suggestions: ['Suggestion 2']
          }
        }
        mail = GiftReminderMailer.gift_reminder(user, event, gift_summary_multi)
        
        expect(mail.body.encoded).to include(recipient.first_name)
        expect(mail.body.encoded).to include(recipient2.first_name)
      end
    end
  end
end
