class EventReminderMailer < ApplicationMailer
  default from: ENV["MAILER_FROM_EMAIL"] || "noreply@giftwiseapp.com"

  def event_reminder(user, event)
    @user = user
    @event = event
    mail(to: user.email, subject: "Reminder: #{event.name} is coming up!")
  end
end
