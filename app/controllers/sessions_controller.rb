class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      Rails.logger.info("User #{user.id} logged in successfully")
      redirect_to root_path, notice: "Signed in successfully"
    else
      Rails.logger.warn("Failed login attempt for email: #{params[:email]}")
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Rails.logger.info("User #{current_user&.id} logged out")
    reset_session
    redirect_to login_path, notice: "Signed out successfully"
  end
end
