require 'rails_helper'

RSpec.describe 'home/index.html.erb', type: :view do
  let(:user) { create_user(email: 'testview@example.com', password: 'test123') }

  before do
    assign(:current_user, user)
    assign(:upcoming_events, [])
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:logged_in?).and_return(true)
  end

  it 'renders the welcome heading' do
    render
    expect(rendered).to include('Welcome back')
  end

  it 'displays the user greeting with first name' do
    render
    expect(rendered).to include("Welcome back, #{user.first_name}!")
  end

  it 'renders the gift ideas section heading' do
    render
    expect(rendered).to include('Gift Idea Generator')
  end

  context 'with different user first names' do
    it 'displays the correct first name for a different user' do
      other_user = create_user(email: 'other@example.com', password: 'other123', first_name: 'Jane')
      allow(view).to receive(:current_user).and_return(other_user)
      
      render
      expect(rendered).to include("Welcome back, Jane!")
      expect(rendered).not_to include("Welcome back, #{user.first_name}!")
    end
  end

  it 'includes a Contacts link in the navigation when logged in' do
    render template: 'home/index', layout: 'layouts/application'
    expect(rendered).to include('Contacts')
    expect(rendered).to include(contacts_path)
  end
end
