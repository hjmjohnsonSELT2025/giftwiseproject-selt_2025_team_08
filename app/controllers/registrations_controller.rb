class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: "Account created successfully! Please log in with your credentials."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name, :date_of_birth, :gender, :occupation,
      :hobbies, :likes, :dislikes,
      :street, :city, :state, :zip_code, :country
    )
  end
end
