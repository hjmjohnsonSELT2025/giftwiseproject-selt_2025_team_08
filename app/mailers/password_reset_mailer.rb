class PasswordResetMailer < ApplicationMailer
  default from: ENV["MAILER_FROM_EMAIL"] || "noreply@giftwiseapp.com"

  def reset_email(user)
    @user = user
    @reset_url = edit_password_reset_url(token: user.reset_password_token)
    mail(to: user.email, subject: "Reset your GiftWise password")
  end
end
