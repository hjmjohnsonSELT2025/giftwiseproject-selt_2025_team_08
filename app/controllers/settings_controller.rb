class SettingsController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
    @user.build_email_notification_preference if @user.email_notification_preference.blank?
  end

  def update
    @user = current_user
    if @user.update(settings_params)
      redirect_to settings_path, notice: "Settings updated successfully"
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def settings_params
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
end
