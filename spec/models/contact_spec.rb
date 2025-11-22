require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:user) { create_user(email: 'contact-model@example.com') }
  let(:other_user) { create_user(email: 'other-contact@example.com') }

  describe 'associations' do
    it 'belongs to a user' do
      contact = user.contacts.build(contact_user: other_user)
      contact.save
      expect(contact.user).to eq(user)
    end

    it 'belongs to a contact_user' do
      contact = user.contacts.build(contact_user: other_user)
      contact.save
      expect(contact.contact_user).to eq(other_user)
    end
  end

  describe 'validations' do
    it 'requires user_id' do
      contact = Contact.new(contact_user: other_user)
      expect(contact).not_to be_valid
      expect(contact.errors[:user_id]).to be_present
    end

    it 'requires contact_user_id' do
      contact = Contact.new(user: user)
      expect(contact).not_to be_valid
      expect(contact.errors[:contact_user_id]).to be_present
    end

    it 'enforces uniqueness of contact per user' do
      user.contacts.create(contact_user: other_user)
      duplicate = user.contacts.build(contact_user: other_user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:contact_user_id]).to include('can only be added once per user')
    end

    it 'prevents a user from adding themselves as a contact' do
      contact = user.contacts.build(contact_user: user)
      expect(contact).not_to be_valid
      expect(contact.errors[:contact_user_id]).to include('cannot add yourself as a contact')
    end

    it 'validates that contact_user_id is a valid user' do
      contact = Contact.new(user: user, contact_user_id: 99999)
      expect(contact).not_to be_valid
      expect(contact.errors[:contact_user_id]).to include('must be a valid user')
    end
  end

  describe 'creating a valid contact' do
    it 'creates successfully with valid attributes' do
      expect {
        user.contacts.create(contact_user: other_user, note: 'Test note')
      }.to change(Contact, :count).by(1)
    end

    it 'allows note to be nil' do
      contact = user.contacts.create(contact_user: other_user)
      expect(contact.note).to be_nil
    end

    it 'allows note to be empty string' do
      contact = user.contacts.create(contact_user: other_user, note: '')
      expect(contact.note).to eq('')
    end

    it 'allows long notes' do
      long_note = 'a' * 5000
      contact = user.contacts.create(contact_user: other_user, note: long_note)
      expect(contact.reload.note).to eq(long_note)
    end
  end

  describe 'updating a contact' do
    it 'updates the note' do
      contact = user.contacts.create(contact_user: other_user, note: 'Original')
      contact.update(note: 'Updated')
      expect(contact.reload.note).to eq('Updated')
    end

    it 'clears the note' do
      contact = user.contacts.create(contact_user: other_user, note: 'Original')
      contact.update(note: '')
      expect(contact.reload.note).to eq('')
    end
  end

  describe 'destroying a contact' do
    it 'removes the contact' do
      contact = user.contacts.create(contact_user: other_user)
      contact_id = contact.id
      contact.destroy
      expect(Contact.find_by(id: contact_id)).to be_nil
    end
  end
end
