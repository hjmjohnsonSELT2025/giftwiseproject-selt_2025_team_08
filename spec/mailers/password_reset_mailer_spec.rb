require 'rails_helper'

RSpec.describe PasswordResetMailer, type: :mailer do
  describe '#reset_email' do
    let(:user) { create_user(email: 'resetme@example.com', password: 'password123') }

    before do
      Rails.application.routes.default_url_options[:host] = 'example.com'
    end

    it 'generates a token and includes the edit link in the email' do
      user.generate_password_reset!
      mail = PasswordResetMailer.reset_email(user)

      expect(mail.subject).to eq('Reset your GiftWise password')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to include(ENV['MAILER_FROM_EMAIL'] || 'noreply@giftwiseapp.com')

      # Multipart email: assert against parts directly
      expect(mail.text_part.body.decoded).to include('Reset your password')
      expect(mail.text_part.body.decoded).to include(edit_password_reset_url(token: user.reset_password_token))
      expect(mail.html_part.body.decoded).to include('Reset your password')
      expect(mail.html_part.body.decoded).to include(edit_password_reset_url(token: user.reset_password_token))
    end

    it 'is multipart with both html and text parts' do
      user.generate_password_reset!
      mail = PasswordResetMailer.reset_email(user)

      expect(mail.content_type).to include('multipart/alternative')
      expect(mail.html_part).to be_present
      expect(mail.text_part).to be_present
      expect(mail.text_part.body.decoded).to include('Reset your password')
    end
  end
end
