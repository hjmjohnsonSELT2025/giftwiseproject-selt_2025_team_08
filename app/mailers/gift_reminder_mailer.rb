class GiftReminderMailer < ApplicationMailer
  default from: ENV["MAILER_FROM_EMAIL"] || "noreply@giftwiseapp.com"

  def gift_reminder(user, event, gift_summary)
    @user = user
    @event = event
    @gift_summary = gift_summary
    mail(to: user.email, subject: "Gift Reminder: Get ready for #{event.name}!")
  end
end
