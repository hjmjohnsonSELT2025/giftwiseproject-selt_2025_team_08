require 'rails_helper'

describe "Logging in", type: :request do
  let!(:user) { create_user(email: "test@example.com", password: "password123") }

  it "renders the login page" do
    get login_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Log in")
  end

  it "logs in with valid credentials" do
    post session_path, params: { email: user.email, password: "password123" }
    expect(session[:user_id]).to eq(user.id)
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Signed in successfully")
  end

  it "does not log in with invalid credentials" do
    post session_path, params: { email: user.email, password: "wrongpass" }
    expect(session[:user_id]).to be_nil
    expect(response.body).to include("Invalid email or password")
  end

  it "logs out and clears the session" do
    post session_path, params: { email: user.email, password: "password123" }
    delete session_path
    expect(session[:user_id]).to be_nil
    expect(response).to redirect_to(login_path)
    follow_redirect!
    expect(response.body).to include("Signed out successfully")
  end
end
