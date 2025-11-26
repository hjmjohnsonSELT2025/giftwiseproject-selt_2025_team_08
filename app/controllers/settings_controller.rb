class SettingsController < ApplicationController
  before_action :require_login

  # TODO: Add email change functionality with verification
  # TODO: Add password change functionality

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(settings_params)
      Rails.logger.info("User #{@user.id} updated their settings")
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
      :street, :city, :state, :zip_code, :country
    )
  end
end
