class CheckNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    NotificationService.check_and_send_reminders
  end
end
