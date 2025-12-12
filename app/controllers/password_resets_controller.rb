class PasswordResetsController < ApplicationController
  before_action :load_user_by_token, only: [:edit, :update]

  def new
  end

  def create
    if (user = User.find_by(email: params[:email].to_s.downcase.strip))
      user.generate_password_reset!
      PasswordResetMailer.reset_email(user).deliver_now
      Rails.logger.info("Password reset email queued for user ##{user.id}")
    else
      Rails.logger.warn("Password reset requested for non-existent email: #{params[:email]}")
    end
    redirect_to login_path, notice: "If that email address exists in our system, you will receive a password reset link shortly."
  end

  def edit
  end

  def update
    unless @user.password_reset_token_valid?
      redirect_to new_password_reset_path, alert: "Your password reset link has expired. Please request a new one." and return
    end

    if params[:password].blank? || params[:password_confirmation].blank?
      flash.now[:alert] = "Password and confirmation are required"
      render :edit, status: :unprocessable_entity and return
    end

    if params[:password] != params[:password_confirmation]
      flash.now[:alert] = "Password confirmation does not match"
      render :edit, status: :unprocessable_entity and return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      @user.clear_password_reset!
      redirect_to login_path, notice: "Your password has been reset. Please sign in."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_user_by_token
    @user = User.find_by(reset_password_token: params[:token])
    unless @user
      redirect_to new_password_reset_path, alert: "Invalid password reset link. Please request a new one."
    end
  end
end
