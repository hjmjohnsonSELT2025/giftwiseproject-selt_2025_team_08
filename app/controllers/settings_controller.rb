class SettingsController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
    @user.build_email_notification_preference if @user.email_notification_preference.blank?
  end

  def credentials
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      Rails.logger.info("User #{@user.id} updated their settings")
      redirect_to settings_path, notice: "Settings updated successfully"
    else
      render :show, status: :unprocessable_content
    end
  end

  def update_credentials
    @user = current_user


    unless @user.authenticate(params[:current_password].to_s)
      @user.assign_attributes(credential_params.except(:password, :password_confirmation))
      @user.errors.add(:current_password, 'is incorrect')
      return render :credentials, status: :unprocessable_content
    end

    if params.dig(:user, :password).blank?
      params[:user]&.delete(:password)
      params[:user]&.delete(:password_confirmation)
    end

    if @user.update(credential_params)
      Rails.logger.info("User #{@user.id} updated their credentials")
      redirect_to settings_path, notice: "Account credentials updated successfully"
    else
      render :credentials, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :first_name, :last_name, :date_of_birth, :gender, :occupation,
      :hobbies, :likes, :dislikes,
      :street, :city, :state, :zip_code, :country,
      email_notification_preference_attributes: [
        :id, :event_reminders_enabled, :event_reminder_timing,
        :gift_reminders_enabled, :gift_reminder_timing
      ]
    )
  end

  def credential_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
