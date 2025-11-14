require 'rails_helper'

RSpec.describe User, type: :model do
  it 'validates presence of email' do
    user = User.new(password: 'password')
    expect(user).not_to be_valid
    expect(user.errors[:email]).to be_present
  end

  it 'authenticates with correct password' do
    user = User.create!(email: 'test@example.com', password: 'secret', password_confirmation: 'secret')
    expect(user.authenticate('secret')).to eq(user)
  end
end
