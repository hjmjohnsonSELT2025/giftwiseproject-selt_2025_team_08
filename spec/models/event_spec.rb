require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to have_many(:event_attendees).dependent(:destroy) }
    it { is_expected.to have_many(:attendees).through(:event_attendees).source(:user) }
    it { is_expected.to have_many(:recipients).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_at) }
    it { is_expected.to validate_presence_of(:end_at) }
    it { is_expected.to validate_presence_of(:theme) }

    it 'rejects invalid theme' do
      user = create(:user)
      event = build(:event, creator: user, theme: 'InvalidTheme')
      expect(event).not_to be_valid
      expect(event.errors[:theme]).to include('is not a valid theme')
    end

    it 'accepts valid theme' do
      user = create(:user)
      Event::THEMES.each do |valid_theme|
        event = build(:event, creator: user, theme: valid_theme)
        expect(event).to be_valid
      end
    end
  end

  describe 'theme' do
    it 'has all expected themes' do
      expect(Event::THEMES).to include('Birthday', 'Wedding', 'Anniversary', 'Holiday', 'Graduation', 'Baby Shower', 'Retirement', 'General')
      expect(Event::THEMES.count).to eq(8)
    end

    it 'requires theme to be set' do
      event = build(:event, theme: nil)
      expect(event).not_to be_valid
      expect(event.errors[:theme]).to include("can't be blank")
    end

    it 'persists theme to database' do
      organizer = create(:user)
      event = create(:event, creator: organizer, theme: 'Wedding')
      
      reloaded = Event.find(event.id)
      expect(reloaded.theme).to eq('Wedding')
    end

    it 'can update theme' do
      event = create(:event, theme: 'Birthday')
      event.update(theme: 'Anniversary')
      
      expect(event.reload.theme).to eq('Anniversary')
    end
  end
end
